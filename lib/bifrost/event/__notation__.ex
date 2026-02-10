defmodule Bifrost.Event.Notation do
  @moduledoc ~S"""
  Notation for defining Bifrost events.
  """

  @doc ~S"""
  Use it to define a Bifrost event.
  """
  defmacro __using__(_) do
    quote do
      @behaviour Bifrost.Event

      import unquote(__MODULE__), only: [defevent: 1]

      alias Zot, as: Z
      alias Bifrost.Event.ZotCustom, as: Zc
    end
  end

  @doc ~S"""
  Defines a new event using Zot.
  """
  defmacro defevent(ast) do
    ast_fields = Keyword.keys(ast)
    fields = ast_fields ++ [__bifrost_event_payload__: true]

    quote do
      @schema unquote(ast)
              |> Map.new()
              |> Zot.strict_map()

      @derive {Jason.Encoder, only: unquote(ast_fields)}
      defstruct unquote(fields)

      @impl Bifrost.Event
      def meta(:schema), do: @schema

      @impl Bifrost.Event
      def parse(params), do: unquote(__MODULE__).parse(__MODULE__, @schema, params)

      @impl Bifrost.Event
      def parse!(params), do: unquote(__MODULE__).parse!(__MODULE__, @schema, params)

      @impl Bifrost.Event
      def to_map(%__MODULE__{} = payload), do: unquote(__MODULE__).to_map(payload)
    end
  end

  @doc false
  def parse(mod, schema, params) do
    with {:ok, params} <- Zot.parse(schema, params, coerce: true),
          do: {:ok, struct!(mod, params)}
  end

  @doc false
  def parse!(mod, schema, params) do
    case parse(mod, schema, params) do
      {:ok, payload} -> payload
      {:error, issues} -> raise(ArgumentError, Zot.summarize(issues))
    end
  end

  @doc false
  def to_map(%_{__bifrost_event_payload__: true} = payload) do
    payload
    |> Map.from_struct()
    |> Map.delete(:__bifrost_event_payload__)
  end
end
