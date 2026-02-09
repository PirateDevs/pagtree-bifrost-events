defmodule Tesseract.Event.SettlementSucceeded do
  @moduledoc ~S"""
  Event emitted when a Settlement has succeeded.
  """

  use Tesseract.Event.Notation

  @split Z.strict_map(%{
           provider_id: Zc.non_empty_string(),
           paid_amount: Zc.money(:cents),
           provider_pricing_percentage: Zc.percentage(),
           provider_pricing_fixed_amount: Zc.money(:cents),
           provider_fee: Zc.money(:cents),
           sent_at: Z.date_time()
         })

  defevent splits: Z.list(@split, min: 1),
           #   info that was already sent in previous events but
           # ↓ that's needed again to create the wallet transactions
           more: Z.strict_map(%{
             currency: Zc.currency(),
             paid_amount: Zc.money(:cents),
             platform_fee: Zc.money(:cents)
           })
end
