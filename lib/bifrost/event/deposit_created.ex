defmodule Bifrost.Event.DepositCreated do
  @moduledoc ~S"""
  Event emitted when a deposit has been created.
  """

  use Bifrost.Event.Notation

  defevent request_id: Zc.non_empty_string() |> Z.optional(),
           # ↑ missing on manual deposits
           end_to_end_id: Zc.non_empty_string() |> Z.optional(),
           # ↑ 1. only available to pix payments
           #   2. most providers only provide it when the payment succeeds
           #   3. might be missing on manual deposits
           provider_id: Zc.non_empty_string(),
           provider_deposit_id: Zc.non_empty_string() |> Z.optional(),
           # ↑ missing on manual deposits
           currency: Zc.currency(),
           amount: Zc.money(:cents),
           # ↓ the merchant's info or nil
           payer: Zc.contact() |> Z.default(%{})
end
