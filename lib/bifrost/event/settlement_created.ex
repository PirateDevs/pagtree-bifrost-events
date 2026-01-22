defmodule Bifrost.Event.SettlementCreated do
  @moduledoc ~S"""
  Event emitted when a Settlement has been created.
  """

  use Bifrost.Event.Notation

  defevent currency: Zc.currency(),
           amount: Zc.money(:cents),
           platform_pricing_percentage: Zc.percentage(),
           platform_pricing_fixed_amount: Zc.money(:cents),
           platform_fee: Zc.money(:cents),
           meta: Zc.meta() |> Z.default(%{}),
           idempotency_key: Zc.non_empty_string() |> Z.optional()
end
