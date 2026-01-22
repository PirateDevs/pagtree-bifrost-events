defmodule Bifrost.Event.PaymentCanceled do
  @moduledoc ~S"""
  Event emitted when a Payment has been canceled or has expired.
  """

  use Bifrost.Event.Notation

  defevent canceled_reason: Zc.non_empty_string() |> Z.optional()
end
