defmodule Bifrost.Event.DepositSucceeded do
  @moduledoc ~S"""
  Event emitted when a deposit has succeeded.
  """

  use Bifrost.Event.Notation

  defevent end_to_end_id: Zc.non_empty_string() |> Z.optional(),
           # ↑ 1. only available on pix deposits
           #   2. missing on manual deposits
           paid_amount: Zc.money(:cents),
           provider_pricing_percentage: Zc.percentage(),
           provider_pricing_fixed_amount: Zc.money(:cents),
           provider_fee: Zc.money(:cents),
           platform_pricing_percentage: Zc.percentage(),
           platform_pricing_fixed_amount: Zc.money(:cents),
           platform_fee: Zc.money(:cents)
end
