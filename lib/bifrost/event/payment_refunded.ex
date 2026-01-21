defmodule Bifrost.Event.PaymentRefunded do
  @moduledoc ~S"""
  Event emitted when a Payment has been refunded.
  """

  use Bifrost.Event.Notation

  defevent payment_id: Zc.non_empty_string(),
           refunded_amount: Zc.money(),
           refunded_reason: Zc.non_empty_string() |> Z.optional()
end
