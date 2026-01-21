defmodule Bifrost.Event.Notation do
  @moduledoc ~S"""
  Notation for defining Bifrost events.
  """

  @doc ~S"""
  Use it to define a Bifrost event.
  """
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__), only: [defevent: 1]

      alias Zot, as: Z
      alias Bifrost.Event.ZotCustom, as: Zc

      defimpl Jason.Encoder do
        def encode(event, opts) do
          event
          |> Map.from_struct()
          |> Map.delete(:__bifrost_event__)
          |> Jason.Encode.map(opts)
        end
      end
    end
  end

  @doc ~S"""
  Defines a new event using Zot.
  """
  defmacro defevent(ast) do
    fields = Keyword.keys(ast) ++ [__bifrost_event__: true]

    quote do
      @schema unquote(ast)
              |> Map.new()
              |> Zot.strict_map()

      defstruct unquote(fields)

      @doc ~S"""
      Returns metadata about the event.
      """
      @spec meta(atom) :: term

      def meta(:schema), do: @schema

      @doc ~S"""
      Parses the event from the given params.
      """
      @spec parse(map) :: {:ok, %__MODULE__{}} | {:error, [Zot.Issue.t(), ...]}

      def parse(params) do
        with {:ok, params} <- Zot.parse(@schema, params, coerce: true),
             do: {:ok, struct!(__MODULE__, params)}
      end

      @doc ~S"""
      Same as `parse/1` but raises on parsing or validation errors.
      """
      @spec parse!(map) :: %__MODULE__{}

      def parse!(params) do
        case parse(params) do
          {:ok, struct} -> struct
          {:error, issues} -> raise(ArgumentError, Zot.Issue.summarize(issues))
        end
      end
    end
  end
end
