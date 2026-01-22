defmodule Bifrost.Event.SettlementSucceeded do
  @moduledoc ~S"""
  Event emitted when a Settlement has succeeded.
  """

  use Bifrost.Event.Notation

  defevent splits:
             Z.strict_map(%{
               id: Zc.non_empty_string(),
               provider_id: Zc.non_empty_string(),
               paid_amount: Zc.money(:cents),
               provider_pricing_percentage: Zc.percentage(),
               provider_pricing_fixed_amount: Zc.money(:cents),
               provider_fee: Zc.money(:cents),
               sent_at: Z.date_time()
             })
             |> Z.list(min: 1)
end
