defmodule Bifrost.Event.ZotCustom do
  @moduledoc ~S"""
  Zot custom types.
  """

  alias __MODULE__, as: Zc
  alias Zot, as: Z

  @doc false
  def contact do
    Z.strict_map(%{
      name: Zc.non_empty_string(),
      document: Zc.non_empty_string(),
      email: Zc.non_empty_string(),
      phone: Zc.non_empty_string(),
      meta: Zc.meta() |> Z.default(%{})
    })
    |> Z.partial()
  end

  @doc false
  def currency, do: Z.enum([:BRL, :CRC])

  @doc false
  def env_type, do: Z.enum([:live, :sandbox])

  @doc false
  def meta do
    [Z.string(max: 255), Z.number(), Z.boolean()]
    |> Z.union()
    |> Z.record()
  end

  @doc false
  def money, do: Z.int(min: 0)

  @doc false
  def non_empty_string, do: Z.string(trim: true, min: 1)
end
