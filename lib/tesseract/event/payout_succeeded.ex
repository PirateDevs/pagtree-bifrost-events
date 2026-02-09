defmodule Tesseract.Event.PayoutSucceeded do
  @moduledoc ~S"""
  Event emitted when a Payout has succeeded.
  """

  use Tesseract.Event.Notation

  defevent end_to_end_id: Zc.non_empty_string() |> Z.optional(),
           # ↑ 1. only available to pix payouts
           #   2. most providers only provide it when the payout succeeds
           provider_id: Zc.non_empty_string(),
           provider_payout_id: Zc.non_empty_string(),
           # ↑ there's some records where this is missing, probably tests
           provider_pricing_percentage: Zc.percentage(),
           provider_pricing_fixed_amount: Zc.money(:cents),
           provider_fee: Zc.money(:cents),
           receiver: Zc.contact() |> Z.default(%{}),
           #   info that was already sent in previous events but
           # ↓ that's needed again to create the wallet transactions
           more: Z.strict_map(%{
             currency: Zc.currency(),
             amount: Zc.money(:cents),
             platform_fee: Zc.money(:cents)
           })
end
