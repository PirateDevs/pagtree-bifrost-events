defmodule Bifrost.Event.SettlementSucceeded do
  @moduledoc ~S"""
  Event emitted when a Settlement has succeeded.
  """

  use Bifrost.Event.Notation

  defevent settlement_id: Zc.non_empty_string(),
           splits:
             Z.strict_map(%{
               id: Zc.non_empty_string(),
               provider_id: Zc.non_empty_string(),
               amount: Zc.money(),
               provider_fee: Zc.money(),
               sent_at: Z.date_time()
             })
             |> Z.list(min: 1)
end
