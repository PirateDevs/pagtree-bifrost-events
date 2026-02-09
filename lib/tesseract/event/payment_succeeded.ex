defmodule Tesseract.Event.PaymentSucceeded do
  @moduledoc ~S"""
  Event emitted when a payment has succeeded.
  """

  use Tesseract.Event.Notation

  defevent end_to_end_id: Zc.non_empty_string() |> Z.optional(),
           # ↑ only available on pix payments
           paid_amount: Zc.money(:cents),
           provider_pricing_percentage: Zc.percentage(),
           provider_pricing_fixed_amount: Zc.money(:cents),
           provider_fee: Zc.money(:cents),
           platform_pricing_percentage: Zc.percentage(),
           platform_pricing_fixed_amount: Zc.money(:cents),
           platform_fee: Zc.money(:cents),
           payer: Zc.contact() |> Z.default(%{}),
           #   info that was already sent in previous events but
           # ↓ that's needed again to create the wallet transactions
           more: Z.strict_map(%{
             provider_id: Zc.non_empty_string(),
             currency: Zc.currency()
           })
end
