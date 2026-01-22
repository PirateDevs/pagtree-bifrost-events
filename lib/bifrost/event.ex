defmodule Bifrost.Event do
  @moduledoc ~S"""
  Captures a single change event within the system.
  """

  alias __MODULE__, as: Event
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

  @type t :: %Event{
          id: pos_integer,
          type: atom,
          merchant_id: String.t(),
          env_type: :live | :sandbox,
          subject_id: String.t(),
          payload:
            %PaymentCanceled{}
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

  @types [
    :payment_canceled,
    :payment_created,
    :payment_refunded,
    :payment_succeeded,
    :payout_canceled,
    :payout_created,
    :payout_refunded,
    :payout_succeeded,
    :settlement_created,
    :settlement_succeeded
  ]

  @base Z.strict_map(%{
          id: Z.int(min: 1),
          merchant_id: Z.string(trim: true, min: 1),
          env_type: Z.enum(@envs),
          subject_id: Z.string(trim: true, min: 1),
          timestamp: Z.date_time()
        })

  @schema Z.discriminated_union(:type, [
            Z.strict_map(%{type: Z.literal(:payment_canceled),     payload: PaymentCanceled.meta(:schema)})     |> Z.merge(@base),
            Z.strict_map(%{type: Z.literal(:payment_created),      payload: PaymentCreated.meta(:schema)})      |> Z.merge(@base),
            Z.strict_map(%{type: Z.literal(:payment_refunded),     payload: PaymentRefunded.meta(:schema)})     |> Z.merge(@base),
            Z.strict_map(%{type: Z.literal(:payment_succeeded),    payload: PaymentSucceeded.meta(:schema)})    |> Z.merge(@base),
            Z.strict_map(%{type: Z.literal(:payout_canceled),      payload: PayoutCanceled.meta(:schema)})      |> Z.merge(@base),
            Z.strict_map(%{type: Z.literal(:payout_created),       payload: PayoutCreated.meta(:schema)})       |> Z.merge(@base),
            Z.strict_map(%{type: Z.literal(:payout_refunded),      payload: PayoutRefunded.meta(:schema)})      |> Z.merge(@base),
            Z.strict_map(%{type: Z.literal(:payout_succeeded),     payload: PayoutSucceeded.meta(:schema)})     |> Z.merge(@base),
            Z.strict_map(%{type: Z.literal(:settlement_created),   payload: SettlementCreated.meta(:schema)})   |> Z.merge(@base),
            Z.strict_map(%{type: Z.literal(:settlement_succeeded), payload: SettlementSucceeded.meta(:schema)}) |> Z.merge(@base)
          ])

  @doc ~S"""
  Returns metadata about this struct.
  """
  @spec meta(atom) :: term

  def meta(:envs), do: @envs
  def meta(:schema), do: @schema
  def meta(:types), do: @types

  @doc ~S"""
  Parses and validates the given params into a Bifrost event.
  """
  @spec parse(term) :: {:ok, %Event{}} | {:error, [Zot.Issue.t(), ...]}

  def parse(params) do
    with {:ok, data} <- Z.parse(@schema, params, coerce: true),
         do: {:ok, struct!(__MODULE__, data)}
  end

  @doc ~S"""
  Same as `parse/1` but raises on error if parsing / validation fails.
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
