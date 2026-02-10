defmodule Bifrost.Outbox do
  @moduledoc ~S"""
  A store of outgoing Bifrost events.
  """

  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query
  import Bifrost.Event, only: [parse!: 1]

  alias __MODULE__

  @typedoc ~S"""
  """
  @type t :: %Outbox{
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

  @primary_key {:id, :id, autogenerate: true}
  schema "bifrost_outbox" do
    field :type, Ecto.Enum, values: @types
    field :merchant_id, :string
    field :env_type, Ecto.Enum, values: @envs
    field :subject_id, :string
    field :payload, :map

    timestamps inserted_at: :timestamp,
               updated_at: false,
               type: :utc_datetime_usec
  end

  @doc ~S"""
  Creates a changeset for an outbox record.
  """
  @spec changeset(record, params) :: Ecto.Changeset.t()
        when record: t,
             params: map

  def changeset(%Outbox{} = record \\ %Outbox{}, %{} = params) do
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
    Enum.reduce(filters, from(event in Outbox, order_by: [asc: event.id]), fn
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
  Converts an outbox record into a Bifrost Event struct.
  """
  @spec to_event!(t) :: Bifrost.Event.t()

  def to_event!(%Outbox{} = record) do
    record
    |> Map.from_struct()
    |> Map.delete(:__meta__)
    |> parse!()
  end
end
