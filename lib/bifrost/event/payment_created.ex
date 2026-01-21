defmodule Bifrost.Event.PaymentCreated do
  @moduledoc ~S"""
  Event emitted when a Payment is created.
  """

  use Bifrost.Event.Notation

  @iban Z.strict_map(%{
          type: Z.literal(:bank_transfer_iban),
          bank_transfer_iban:
            Z.strict_map(%{
              beneficiary_name: Zc.non_empty_string(),
              beneficiary_document: Zc.non_empty_string(),
              bank: Zc.non_empty_string(),
              iban: Zc.non_empty_string(),
              correlation_key: Zc.non_empty_string()
            })
        })

  @pix Z.strict_map(%{
         type: Z.literal(:pix),
         pix: Z.strict_map(%{uri: Z.uri()})
       })

  @sinpe Z.strict_map(%{
           type: Z.literal(:sinpe_movil),
           sinpe_movil:
             Z.strict_map(%{
               beneficiary_name: Zc.non_empty_string(),
               beneficiary_document: Zc.non_empty_string(),
               bank: Zc.non_empty_string() |> Z.optional(),
               movil: Zc.non_empty_string(),
               correlation_key: Zc.non_empty_string()
             })
         })

  @method Z.discriminated_union(:type, [
            @iban,
            @pix,
            @sinpe
          ])

  defevent payment_id: Zc.non_empty_string(),
           request_id: Zc.non_empty_string(),
           provider_id: Zc.non_empty_string(),
           provider_payment_id: Zc.non_empty_string(),
           product_pricing_percentage: Z.float(min: 0),
           product_pricing_fixed_amount: Zc.money(),
           end_to_end_id: Zc.non_empty_string() |> Z.optional(),
           currency: Zc.currency(),
           amount: Zc.money(),
           customer: Zc.contact() |> Z.default(%{}),
           method: @method,
           meta: Zc.meta() |> Z.default(%{}),
           idempotency_key: Zc.non_empty_string() |> Z.optional(),
           expires_at: Z.date_time()
end
