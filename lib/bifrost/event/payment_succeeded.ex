defmodule Bifrost.Event.PaymentSucceeded do
  @moduledoc ~S"""
  Event emitted when a payment has succeeded.
  """

  use Bifrost.Event.Notation

  defevent payment_id: Zc.non_empty_string(),
           end_to_end_id: Zc.non_empty_string() |> Z.optional(),
           paid_amount: Zc.money(),
           provider_fee: Zc.money(),
           platform_fee: Zc.money(),
           payer: Zc.contact() |> Z.default(%{})
end
