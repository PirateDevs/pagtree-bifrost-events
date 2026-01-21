defmodule Bifrost.Event.PayoutCanceled do
  @moduledoc ~S"""
  Event emitted when a payout has been canceled or has expired.
  """

  use Bifrost.Event.Notation

  defevent payout_id: Zc.non_empty_string(),
           canceled_reason: Zc.non_empty_string() |> Z.optional()
end
