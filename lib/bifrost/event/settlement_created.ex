defmodule Bifrost.Event.SettlementCreated do
  @moduledoc ~S"""
  Event emitted when a Settlement has been created.
  """

  use Bifrost.Event.Notation

  defevent settlement_id: Zc.non_empty_string(),
           product_pricing_percentage: Z.float(min: 0),
           product_pricing_fixed_amount: Zc.money(),
           currency: Zc.currency(),
           amount: Zc.money(),
           platform_fee: Zc.money(),
           meta: Zc.meta() |> Z.default(%{}),
           idempotency_key: Zc.non_empty_string() |> Z.optional()
end
