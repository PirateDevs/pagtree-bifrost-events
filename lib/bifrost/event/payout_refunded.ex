defmodule Bifrost.Event.PayoutRefunded do
  @moduledoc ~S"""
  Event emitted when a Payout has been refunded.
  """

  use Bifrost.Event.Notation

  defevent refunded_amount: Zc.money(:cents),
           refunded_reason: Z.string(trim: true) |> Zc.empty_as_nil() |> Z.optional()
end
