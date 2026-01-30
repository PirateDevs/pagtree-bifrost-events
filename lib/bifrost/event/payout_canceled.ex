defmodule Bifrost.Event.PayoutCanceled do
  @moduledoc ~S"""
  Event emitted when a payout has been canceled or has expired.
  """

  use Bifrost.Event.Notation

  defevent canceled_reason: Z.string(trim: true) |> Zc.empty_as_nil() |> Z.optional(),
           #   info that was already sent in previous events but
           # ↓ that's needed again to create the wallet transactions
           more: Z.strict_map(%{
             currency: Zc.currency(),
             amount: Zc.money(:cents),
             platform_fee: Zc.money(:cents)
           })
end
