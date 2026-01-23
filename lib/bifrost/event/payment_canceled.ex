defmodule Bifrost.Event.PaymentCanceled do
  @moduledoc ~S"""
  Event emitted when a Payment has been canceled or has expired.
  """

  use Bifrost.Event.Notation

  defevent canceled_reason: Z.string(trim: true) |> Zc.empty_as_nil() |> Z.optional()
end
