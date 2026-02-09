defmodule Tesseract.Event.PayoutRefunded do
  @moduledoc ~S"""
  Event emitted when a Payout has been refunded.
  """

  use Tesseract.Event.Notation

  defevent refunded_amount: Zc.money(:cents),
           refunded_reason: Z.string(trim: true) |> Zc.empty_as_nil() |> Z.optional(),
           #   info that was already sent in previous events but
           # ↓ that's needed again to create the wallet transactions
           more: Z.strict_map(%{
             provider_id: Zc.non_empty_string(),
             currency: Zc.currency(),
             platform_fee: Zc.money(:cents)
           })
end
