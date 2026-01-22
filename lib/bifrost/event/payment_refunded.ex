defmodule Bifrost.Event.PaymentRefunded do
  @moduledoc ~S"""
  Event emitted when a Payment has been refunded.
  """

  use Bifrost.Event.Notation

  defevent refunded_amount: Zc.money(:cents),
           refunded_reason: Zc.non_empty_string() |> Z.optional()
end
