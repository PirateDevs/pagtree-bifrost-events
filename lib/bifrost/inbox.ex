defmodule Bifrost.Inbox do
  @moduledoc ~S"""
  A store of incoming Bifrost events.
  """

  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query
  import Bifrost.Event, only: [from_etf!: 1, parse!: 1, to_map: 1]

  alias __MODULE__
  alias Bifrost.Event

  @typedoc ~S"""
  """
  @type t :: %Inbox{
          id: pos_integer,
          type: atom,
          merchant_id: String.t(),
          env_type: :live | :sandbox,
          subject_id: String.t(),
          payload: map,
          timestamp: DateTime.t()
        }

  @types Bifrost.Event.meta(:types)
  @envs Bifrost.Event.meta(:envs)

  @primary_key {:id, :id, []}
  schema "bifrost_inbox" do
    field :type, Ecto.Enum, values: @types
    field :merchant_id, :string
    field :env_type, Ecto.Enum, values: @envs
    field :subject_id, :string
    field :payload, :map
    field :timestamp, :utc_datetime_usec
  end

  @doc ~S"""
  Creates a changeset for an inbox record.
  """
  @spec changeset(record, params) :: Ecto.Changeset.t()
        when record: t,
             params: map

  def changeset(%Inbox{} = record \\ %Inbox{}, %{} = params) do
    record
    |> cast(params, [:type, :merchant_id, :env_type, :subject_id, :payload, :timestamp])
    |> validate_required([:type, :merchant_id, :env_type, :subject_id, :payload])
    |> validate_inclusion(:type, @types)
    |> validate_length(:merchant_id, min: 1, max: 36)
    |> validate_inclusion(:env_type, @envs)
    |> validate_length(:subject_id, min: 1, max: 36)
  end

  @doc ~S"""
  Returns an Ecto query for fetching events from the inbox, applying
  the given filters.
  """
  @spec query([filter, ...]) :: Ecto.Queryable.t()
        when filter:
               {:merchant_id, String.t()}
               | {:after, non_neg_integer}
               | {:take, pos_integer}

  def query(filters \\ []) when is_list(filters) do
    Enum.reduce(filters, from(event in Inbox, order_by: [asc: event.id]), fn
      {_, nil},                          query -> query
      {:type, in: [_ | _] = types},      query -> where(query, [event], event.type in ^types)
      {:type, type},                     query -> where(query, [event], event.type == ^type)
      {:merchant_id, in: [_ | _] = ids}, query -> where(query, [event], event.merchant_id in ^ids)
      {:merchant_id, id},                query -> where(query, [event], event.merchant_id == ^id)
      {:env_type, env_type},             query -> where(query, [event], event.env_type == ^env_type)
      {:subject_id, in: [_ | _] = ids},  query -> where(query, [event], event.subject_id in ^ids)
      {:subject_id, id},                 query -> where(query, [event], event.subject_id == ^id)
      {:timestamp, after: dt},           query -> where(query, [event], event.timestamp > ^dt)
      {:timestamp, before: dt},          query -> where(query, [event], event.timestamp < ^dt)
      {:after, cursor},                  query -> where(query, [event], event.id > ^cursor)
      {:take, n},                        query -> limit(query, ^n)
    end)
  end

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

  def fetch(repo, filters) do
    filters = Keyword.take(filters, [:merchant_id, :after, :take])

    filters
    |> query()
    |> repo.all()
    |> Enum.map(&to_event!/1)
  end

  @doc ~S"""
  Ingests a set of events into the inbox, returning the number of new
  records created. Duplicated events are ignored.
  """
  @spec ingest([etf, ...] | [map, ...] | [event, ...], repo) ::
          {:ok, created_count :: non_neg_integer}
          | {:error, reason :: term}
        when etf: binary,
             event: Bifrost.Event.t(),
             repo: Ecto.Repo.t()

  def ingest([], _), do: {:ok, 0}

  def ingest([%{} = event | _] = events, repo) when is_non_struct_map(event) do
    with {n, _} <- repo.insert_all(Inbox, events, conflict_target: :id, on_conflict: :nothing),
         do: {:ok, n}
  end

  def ingest([%Event{} | _] = events, repo) do
    events
    |> Enum.map(&to_map/1)
    |> ingest(repo)
  end

  def ingest([<<_, _::binary>> | _] = etfs, repo) do
    etfs
    |> Enum.map(&from_etf!/1)
    |> Enum.map(&to_map/1)
    |> ingest(repo)
  end

  @doc ~S"""
  Converts an inbox record into a Bifrost Event struct.
  """
  @spec to_event!(t) :: Bifrost.Event.t()

  def to_event!(%Inbox{} = record) do
    record
    |> Map.from_struct()
    |> Map.delete(:__meta__)
    |> parse!()
  end
end
