defmodule Tesseract.Event.ZotCustom do
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
  def empty_as_nil(%Zot.Type.String{} = type),
    do: Z.transform(type, {__MODULE__, :__empty_as_nil__, []})

  @doc false
  def env_type, do: Z.enum([:live, :sandbox])

  @doc false
  def meta do
    [
      Z.string(max: 255),
      Z.number(),
      Z.boolean(),
      # ↓ throwd away invalid values
      Z.any() |> Z.transform({__MODULE__, :__nil__, []})
    ]
    |> Z.union()
    |> Z.record()
  end

  @doc false
  def money(:cents), do: Z.int(min: 0)

  @doc false
  def non_empty_string, do: Z.string(trim: true, min: 1)

  @doc false
  def percentage(precision \\ 4), do: Z.float(min: 0, max: 1, precision: precision)

  #
  #   CALLBACKS
  #

  @doc false
  def __empty_as_nil__(value)
      when is_binary(value),
      do: with("" <- value, do: nil)

  @doc false
  def __nil__(_), do: nil
end
