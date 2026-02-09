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
    fields = ast_fields ++ [__bifrost_event__: true]

    quote do
      @schema unquote(ast)
              |> Map.new()
              |> Zot.strict_map()

      @derive {Jason.Encoder, only: unquote(ast_fields)}
      defstruct unquote(fields)

      @impl Bifrost.Event
      def meta(:schema), do: @schema

      @impl Bifrost.Event
      def parse(params) do
        with {:ok, params} <- Zot.parse(@schema, params, coerce: true),
             do: {:ok, struct!(__MODULE__, params)}
      end

      @impl Bifrost.Event
      def parse!(params) do
        case parse(params) do
          {:ok, struct} -> struct
          {:error, issues} -> raise(ArgumentError, Zot.Issue.summarize(issues))
        end
      end
    end
  end
end
