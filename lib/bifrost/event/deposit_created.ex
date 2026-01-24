defmodule Bifrost.Event.DepositCreated do
  @moduledoc ~S"""
  Event emitted when a deposit has been created.
  """

  use Bifrost.Event.Notation

  defevent end_to_end_id: Zc.non_empty_string() |> Z.optional(),
           # ↑ 1. only available to pix payments
           #   2. most providers only provide it when the payment succeeds
           #   3. might be missing on manual deposits
           provider_id: Zc.non_empty_string(),
           provider_deposit_id: Zc.non_empty_string() |> Z.optional(),
           # ↑ can be optional because it's possible to have a manual
           #   deposit created by an admin
           currency: Zc.currency(),
           amount: Zc.money(:cents),
           # ↓ the merchant's info or nil
           payer: Zc.contact() |> Z.default(%{})
end
