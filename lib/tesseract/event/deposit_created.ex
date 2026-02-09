defmodule Tesseract.Event.DepositCreated do
  @moduledoc ~S"""
  Event emitted when a deposit has been created.
  """

  use Tesseract.Event.Notation

  defevent provider_id: Zc.non_empty_string(),
           currency: Zc.currency(),
           amount: Zc.money(:cents),
           # ↓ the merchant's info or nil
           payer: Zc.contact() |> Z.default(%{})
end
