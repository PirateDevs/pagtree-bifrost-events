defmodule Bifrost.Event do
  @moduledoc ~S"""
  Captures an atomic-change event within the system.
  """

  alias __MODULE__, as: Event
  alias Bifrost.Event.DepositCreated
  alias Bifrost.Event.DepositSucceeded
  alias Bifrost.Event.PaymentCanceled
  alias Bifrost.Event.PaymentCreated
  alias Bifrost.Event.PaymentRefunded
  alias Bifrost.Event.PaymentSucceeded
  alias Bifrost.Event.PayoutCanceled
  alias Bifrost.Event.PayoutCreated
  alias Bifrost.Event.PayoutRefunded
  alias Bifrost.Event.PayoutSucceeded
  alias Bifrost.Event.SettlementCreated
  alias Bifrost.Event.SettlementSucceeded
  alias Zot, as: Z

  @doc ~S"""
  Returns metadata about the event.
  """
  @callback meta(:schema) :: Zot.Type.Map.t()

  @doc ~S"""
  Parses the event from the given params.
  """
  @callback parse(map) :: {:ok, struct} | {:error, [Zot.Issue.t(), ...]}

  @doc ~S"""
  Parses the event from the given params, raising on parsing or
  validation errors.
  """
  @callback parse!(map) :: struct

  @doc ~S"""
  We keep the `:subject_id` property at the top level so it's easier
  to check for duplicated events by indexing on `[:subject_id, :type]`
  (assumes `:subject_id` is unique across all partitions).
  """
  @type t :: %Event{
          id: pos_integer,
          type: atom,
          merchant_id: String.t(),
          env_type: :live | :sandbox,
          subject_id: String.t(),
          payload: struct,
          timestamp: DateTime.t()
        }

  @derive {Jason.Encoder, only: ~w(id type merchant_id env_type subject_id payload timestamp)a}
  defstruct id: nil,
            type: nil,
            merchant_id: nil,
            env_type: nil,
            subject_id: nil,
            payload: nil,
            timestamp: nil

  @envs [:live, :sandbox]

  @base Z.strict_map(%{
          id: Z.int(min: 1),
          merchant_id: Z.string(trim: true, min: 1, max: 36),
          env_type: Z.enum(@envs),
          subject_id: Z.string(trim: true, min: 1, max: 36),
          timestamp: Z.date_time()
        })

  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  # HOW TO ADD NEW EVENTS                                           #
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  # 1. Create an event module under `lib/bifrost/event/`. See other #
  #    event modules for reference.                                 #
  # 2. Alias the event module at the top of this file. Keep it      #
  #    sorted alphabetically!                                       #
  # 3. Add the event to the `@types` below where the key is the     #
  #    atom event name and the value is the module. Keep it sorted  #
  #    alphabetically and keep the formatting!                      #
  # 4. Add the event to the `@schema` distinct union below. See     #
  #    other events for reference and keep it sorted                #
  #    alphabetically!                                              #
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

  @types [
    deposit_created:      DepositCreated,
    deposit_succeeded:    DepositSucceeded,
    payment_canceled:     PaymentCanceled,
    payment_created:      PaymentCreated,
    payment_refunded:     PaymentRefunded,
    payment_succeeded:    PaymentSucceeded,
    payout_canceled:      PayoutCanceled,
    payout_created:       PayoutCreated,
    payout_refunded:      PayoutRefunded,
    payout_succeeded:     PayoutSucceeded,
    settlement_created:   SettlementCreated,
    settlement_succeeded: SettlementSucceeded
  ]

  # #
  # **IMPORTANT:**
  #   Parsing this schema must produce a plain map - no structs
  #   used. This is important because there are hot operations that
  #   need to parse events where structs would add unnecessary
  #   overhead.
  @schema Z.discriminated_union(:type, [
            Z.strict_map(%{type: Z.literal(:deposit_created),      payload: DepositCreated.meta(:schema)})      |> Z.merge(@base),
            Z.strict_map(%{type: Z.literal(:deposit_succeeded),    payload: DepositSucceeded.meta(:schema)})    |> Z.merge(@base),
            Z.strict_map(%{type: Z.literal(:payment_canceled),     payload: PaymentCanceled.meta(:schema)})     |> Z.merge(@base),
            Z.strict_map(%{type: Z.literal(:payment_created),      payload: PaymentCreated.meta(:schema)})      |> Z.merge(@base),
            Z.strict_map(%{type: Z.literal(:payment_refunded),     payload: PaymentRefunded.meta(:schema)})     |> Z.merge(@base),
            Z.strict_map(%{type: Z.literal(:payment_succeeded),    payload: PaymentSucceeded.meta(:schema)})    |> Z.merge(@base),
            Z.strict_map(%{type: Z.literal(:payout_canceled),      payload: PayoutCanceled.meta(:schema)})      |> Z.merge(@base),
            Z.strict_map(%{type: Z.literal(:payout_created),       payload: PayoutCreated.meta(:schema)})       |> Z.merge(@base),
            Z.strict_map(%{type: Z.literal(:payout_refunded),      payload: PayoutRefunded.meta(:schema)})      |> Z.merge(@base),
            Z.strict_map(%{type: Z.literal(:payout_succeeded),     payload: PayoutSucceeded.meta(:schema)})     |> Z.merge(@base),
            Z.strict_map(%{type: Z.literal(:settlement_created),   payload: SettlementCreated.meta(:schema)})   |> Z.merge(@base),
            Z.strict_map(%{type: Z.literal(:settlement_succeeded), payload: SettlementSucceeded.meta(:schema)}) |> Z.merge(@base),
          ])

  @doc ~S"""
  Pattern matches an event by its payload module.
  """
  defmacro event(mod) do
    quote do
      %unquote(__MODULE__){payload: %unquote(mod){}}
    end
  end

  @doc ~S"""
  Returns metadata about this struct.
  """
  @spec meta(:envs) :: [atom, ...]
  @spec meta(:schema) :: Zot.Type.Map.t()
  @spec meta(:types) :: [atom, ...]

  def meta(:envs), do: @envs
  def meta(:schema), do: @schema
  def meta(:types), do: Keyword.keys(@types)

  @doc ~S"""
  Parses and validates the given params into a `Bifrost.Event`.
  """
  @spec parse(map) :: {:ok, t} | {:error, [Zot.Issue.t(), ...]}

  def parse(params) do
    with {:ok, data} <- Z.parse(@schema, params, coerce: true),
         do: {:ok, struct!(__MODULE__, %{data | payload: s!(data.type, data.payload)})}
  end

  for {event, mod} <- @types do
    defp s!(unquote(event), payload), do: struct!(unquote(mod), payload)
  end

  @doc ~S"""
  Parses and validates the given params into a `Bifrost.Event`,
  raising on parsing or validation errors.
  """
  @spec parse!(map) :: t

  def parse!(params) do
    case parse(params) do
      {:ok, event} -> event
      {:error, issues} -> raise(Zot.Issue.pretty_print(issues))
    end
  end
end
