defmodule Bifrost.Event.PayoutSucceeded do
  @moduledoc ~S"""
  Event emitted when a Payout has succeeded.
  """

  use Bifrost.Event.Notation

  defevent payout_id: Zc.non_empty_string(),
           provider_id: Zc.non_empty_string(),
           provider_payout_id: Zc.non_empty_string() |> Z.optional(),
           end_to_end_id: Zc.non_empty_string() |> Z.optional(),
           provider_fee: Zc.money(),
           platform_fee: Zc.money(),
           receiver: Zc.contact() |> Z.default(%{})
end
