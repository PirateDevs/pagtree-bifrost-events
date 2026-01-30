defmodule Bifrost.Event do
  @moduledoc ~S"""
  Captures a single change event within the system.
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

  @doc false
  @type t :: %Event{
          id: pos_integer,
          type: atom,
          merchant_id: String.t(),
          env_type: :live | :sandbox,
          subject_id: String.t(),
          payload:
            %DepositCreated{}
            | %DepositSucceeded{}
            | %PaymentCanceled{}
            | %PaymentCreated{}
            | %PaymentRefunded{}
            | %PaymentSucceeded{}
            | %PayoutCanceled{}
            | %PayoutCreated{}
            | %PayoutRefunded{}
            | %PayoutSucceeded{}
            | %SettlementCreated{}
            | %SettlementSucceeded{},
          timestamp: DateTime.t()
        }

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
          merchant_id: Z.string(trim: true, min: 1),
          env_type: Z.enum(@envs),
          subject_id: Z.string(trim: true, min: 1),
          timestamp: Z.date_time()
        })

  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  # HOW TO ADD NEW EVENTS                                           #
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  # 1. Create an event module under `lib/bifrost/event/`. See other #
  #    event modules for reference.                                 #
  # 2. Alias the event module at the top of this file. Keep it      #
  #    sorted alphabetically!                                       #
  # 3. Add the event to the `@type t` spec under `:payload`. See    #
  #    other events for reference and keep it sorted                #
  #    alphabetically!                                              #
  # 4. Add the event to the `@types` below where the key is the     #
  #    atom event name and the value is the module. Keep it sorted  #
  #    alphabetically!                                              #
  # 5. Add the event to the `@schema` distinct union below. See     #
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
  defmacro event_type(mod) do
    quote do
      %unquote(__MODULE__){payload: %unquote(mod){}}
    end
  end

  @doc ~S"""
  Returns metadata about this struct.
  """
  @spec meta(key) :: [atom, ...] when key: :envs
  @spec meta(key) :: Zot.Type.Map.t() when key: :schema
  @spec meta(key) :: [atom, ...] when key: :types

  def meta(:envs), do: @envs
  def meta(:schema), do: @schema
  def meta(:types), do: Keyword.keys(@types)

  @doc ~S"""
  Parses and validates the given params into a `Bifrost.Event`.
  """
  @spec parse(term) :: {:ok, %Event{}} | {:error, [Zot.Issue.t(), ...]}

  def parse(params) do
    with {:ok, data} <- Z.parse(@schema, params, coerce: true),
         do: {:ok, struct!(__MODULE__, %{data | payload: s!(data.type, data.payload)})}
  end

  for {event, mod} <- @types do
    defp s!(unquote(event), payload), do: struct!(unquote(mod), payload)
  end

  @doc ~S"""
  Parses and validates the given params into a `Bifrost.Event`.

  Same as `parse/1` but raises when failed.
  """
  @spec parse!(term) :: %Event{}

  def parse!(params) do
    case parse(params) do
      {:ok, event} -> event
      {:error, issues} -> raise(Zot.Issue.prettyprint(issues))
    end
  end

  defimpl Jason.Encoder do
    def encode(event, opts), do: Jason.Encode.map(Map.from_struct(event), opts)
  end
end
