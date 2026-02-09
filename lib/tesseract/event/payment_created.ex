defmodule Tesseract.Event.PaymentCreated do
  @moduledoc ~S"""
  Event emitted when a Payment is created.
  """

  use Tesseract.Event.Notation

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
         pix:
         Z.strict_map(%{
            uri: Zc.non_empty_string() |> Z.contains("gov.bcb.pix")
            # ↑ can't use `Z.uri/0` because a pix's URI can have
            #   whitespaces, which is not allowed according to RFC 3986
          })
       })

  @sinpe Z.strict_map(%{
           type: Z.literal(:sinpe_movil),
           sinpe_movil:
             Z.strict_map(%{
               beneficiary_name: Zc.non_empty_string(),
               beneficiary_document: Zc.non_empty_string(),
               bank: Zc.non_empty_string() |> Z.optional(),
               # ↑ there are some records where :bank missing
               movil: Z.numeric(min: 8, max: 9),
               correlation_key: Zc.non_empty_string()
             })
         })

  @method Z.discriminated_union(:type, [
            @iban,
            @pix,
            @sinpe
          ])

  defevent request_id: Zc.non_empty_string() |> Z.optional(),
           provider_id: Zc.non_empty_string(),
           provider_payment_id: Zc.non_empty_string(),
           end_to_end_id: Zc.non_empty_string() |> Z.optional(),
           # ↑ 1. only available to pix payments
           #   2. most providers only provide it when the payment succeeds
           currency: Zc.currency(),
           amount: Zc.money(:cents),
           customer: Zc.contact() |> Z.default(%{}),
           # ↑ only required by some pix payment providers, where they
           #   require the customer's CPF or CNPJ
           method: @method,
           meta: Zc.meta() |> Z.default(%{}),
           idempotency_key: Zc.non_empty_string() |> Z.optional(),
           expires_at: Z.date_time()
end
