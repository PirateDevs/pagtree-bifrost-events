defmodule Bifrost.Event.PayoutRefunded do
  @moduledoc ~S"""
  Event emitted when a Payout has been refunded.
  """

  use Bifrost.Event.Notation

  defevent payout_id: Zc.non_empty_string(),
           refunded_amount: Zc.money(),
           refunded_reason: Zc.non_empty_string() |> Z.optional()
end
