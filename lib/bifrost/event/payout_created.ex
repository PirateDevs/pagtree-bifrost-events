defmodule Bifrost.Event.PayoutCreated do
  @moduledoc ~S"""
  Event emitted when a Payout has been created.
  """

  use Bifrost.Event.Notation

  @iban Z.strict_map(%{
          type: Z.literal(:bank_transfer_iban),
          bank_transfer_iban:
            Z.strict_map(%{
              bank: Zc.non_empty_string() |> Z.optional(),
              # ↑ there are old records on v1 where bank is null / missing
              iban: Zc.non_empty_string()
            })
        })

  @pix Z.strict_map(%{
         type: Z.literal(:pix),
         pix:
           Z.strict_map(%{
             key_type: Z.enum([:cpf, :cnpf, :email, :phone, :random]),
             key: Zc.non_empty_string()
           })
       })

  @sinpe Z.strict_map(%{
           type: Z.literal(:sinpe_movil),
           sinpe_movil: Z.strict_map(%{movil: Zc.non_empty_string()})
         })

  @method Z.discriminated_union(:type, [
            @iban,
            @pix,
            @sinpe
          ])

  defevent payout_id: Zc.non_empty_string(),
           product_pricing_percentage: Z.float(min: 0),
           product_pricing_fixed_amount: Zc.money(),
           currency: Zc.currency(),
           amount: Zc.money(),
           method: @method,
           customer: Zc.contact() |> Z.default(%{}),
           meta: Zc.meta() |> Z.default(%{}),
           idempotency_key: Zc.non_empty_string() |> Z.optional()
end
