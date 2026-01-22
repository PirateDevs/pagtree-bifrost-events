defmodule Bifrost.Event.PayoutSucceeded do
  @moduledoc ~S"""
  Event emitted when a Payout has succeeded.
  """

  use Bifrost.Event.Notation

  defevent end_to_end_id: Zc.non_empty_string() |> Z.optional(),
           # ↑ only available on pix payouts
           provider_id: Zc.non_empty_string(),
           provider_payout_id: Zc.non_empty_string() |> Z.optional(),
           # ↑ there's some records where this is missing, probably tests
           provider_pricing_percentage: Zc.percentage(),
           provider_pricing_fixed_amount: Zc.money(:cents),
           provider_fee: Zc.money(:cents),
           receiver: Zc.contact() |> Z.default(%{})
end
