defmodule Bifrost.Model do
  @moduledoc ~S"""
  Used to define Bifrost models (Inbox and Outbox).

  This module implements common capabilities such as a query builder
  and streaming of records from the database.
  """

  import Bifrost.Event, only: [parse!: 1]
  import Ecto.Query

  @doc ~S"""
  """
  defmacro __using__(_) do
    quote do
      use Ecto.Schema

      @doc ~S"""
      Query builder.
      """
      @spec query([filter, ...]) :: Ecto.Queryable.t()
            when filter:
                   {:merchant_id, String.t()}
                   | {:after, non_neg_integer}
                   | {:take, pos_integer}

      def query(filters), do: unquote(__MODULE__).query(__MODULE__, filters)

      @doc ~S"""
      Fetches many records matching the given filters, returning
      parsed events.
      """
      @spec fetch(repo, [filter, ...]) :: [Bifrost.Event.t()]
            when repo: Ecto.Repo.t(),
                 filter:
                    {:merchant_id, String.t()}
                    | {:after, non_neg_integer}
                    | {:take, pos_integer}

      def fetch(repo, filters), do: unquote(__MODULE__).fetch(repo, __MODULE__, filters)

      @doc ~S"""
      Streams records from the database.
      """
      @spec stream([option, ...]) :: Enumerable.t()
            when option:
                   {:merchant_id, String.t()}
                   | {:after, non_neg_integer}
                   | {:take, pos_integer}

      def stream(repo, opts \\ []), do: unquote(__MODULE__).stream(repo, &query/1, opts)
    end
  end

  @doc ~S"""
  Query builder for the given model.
  """
  @spec query(schema, [filter, ...]) :: Ecto.Queryable.t()
        when schema: Ecto.Schema.t(),
             filter:
               {:merchant_id, String.t()}
               | {:after, non_neg_integer}
               | {:take, pos_integer}

  def query(schema, filters)
      when is_atom(schema) and is_list(filters) do
    Enum.reduce(filters, from(rec in schema, order_by: [asc: rec.id]), fn
      {_, nil},                 query                     -> query
      {:type, in: types},       query when is_list(types) -> where(query, [rec], rec.type in ^types)
      {:type, type},            query                     -> where(query, [rec], rec.type == ^type)
      {:merchant_id, in: ids},  query when is_list(ids)   -> where(query, [rec], rec.merchant_id in ^ids)
      {:merchant_id, id},       query                     -> where(query, [rec], rec.merchant_id == ^id)
      {:env_type, env_type},    query                     -> where(query, [rec], rec.env_type == ^env_type)
      {:subject_id, in: ids},   query when is_list(ids)   -> where(query, [rec], rec.subject_id in ^ids)
      {:subject_id, id},        query                     -> where(query, [rec], rec.subject_id == ^id)
      {:timestamp, after: dt},  query                     -> where(query, [rec], rec.timestamp > ^dt)
      {:timestamp, before: dt}, query                     -> where(query, [rec], rec.timestamp < ^dt)
      {:after, cursor},         query                     -> where(query, [rec], rec.id > ^cursor)
      {:take, n},               query                     -> limit(query, ^n)
    end)
  end

  @doc ~S"""
  Fetches many records matching the given filters, returning
  parsed events.
  """
  @spec fetch(repo, schema, [filter, ...]) :: [Bifrost.Event.t()]
        when repo: Ecto.Repo.t(),
             schema: Ecto.Schema.schema(),
             filter:
               {:merchant_id, String.t()}
               | {:after, non_neg_integer}
               | {:take, pos_integer}

  def fetch(repo, schema, filters) do
    filters = Keyword.take(filters, [:merchant_id, :after, :take])

    schema
    |> query(filters)
    |> repo.all()
    |> Enum.map(&Map.delete(Map.from_struct(&1), :__meta__))
    |> Enum.map(&parse!/1)
  end

  @doc ~S"""
  Streams records from the database using the given `query_builder`
  function and Ecto repository.
  """
  @spec stream(repo, query_builder, [option, ...]) :: Enumerable.t()
        when repo: Ecto.Repo.t(),
             query_builder: (keyword() -> Ecto.Queryable.t()),
             option:
               {:merchant_id, String.t()}
               | {:batch_size, pos_integer}
               | {:after, non_neg_integer}

  def stream(repo, query_builder, opts)
      when is_atom(repo) and is_function(query_builder, 1) and is_list(opts) do
    start_cursor = Keyword.get(opts, :after, 0)
    batch_size = Keyword.get(opts, :batch_size, 500)

    fetcher =
      opts
      |> Keyword.take([:merchant_id])
      |> Keyword.put(:take, batch_size)
      |> create_fetcher(repo, query_builder)

    Stream.resource(fn -> start_cursor end, fetcher, fn _ -> :ok end)
  end

  #
  #   PRIVATE
  #

  defp create_fetcher(defaults, repo, query_builder), do: &fetch(repo, query_builder, defaults, &1)

  defp fetch(repo, query_builder, defaults, cursor) do
    batch_size = Keyword.fetch!(defaults, :take)

    query =
      defaults
      |> Keyword.put(:after, cursor)
      |> query_builder.()

    case repo.all(query) do
      [] -> {:halt, []}
      [_ | _] = recs when length(recs) < batch_size -> {:halt, recs}
      [_ | _] = recs -> {recs, next_cursor(recs)}
    end
  end

  defp next_cursor([_ | _] = records) do
    records
    |> List.last()
    |> Map.fetch!(:id)
  end
end
