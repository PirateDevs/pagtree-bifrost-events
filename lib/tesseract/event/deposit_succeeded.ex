defmodule Tesseract.Event.DepositSucceeded do
  @moduledoc ~S"""
  Event emitted when a deposit has succeeded.
  """

  use Tesseract.Event.Notation

  defevent paid_amount: Zc.money(:cents),
           provider_pricing_percentage: Zc.percentage(),
           provider_pricing_fixed_amount: Zc.money(:cents),
           provider_fee: Zc.money(:cents),
           platform_pricing_percentage: Zc.percentage(),
           platform_pricing_fixed_amount: Zc.money(:cents),
           platform_fee: Zc.money(:cents),
           #   info that was already sent in previous events but
           # ↓ that's needed again to create the wallet transactions
           more: Z.strict_map(%{
             provider_id: Zc.non_empty_string(),
             currency: Zc.currency()
           })
end
