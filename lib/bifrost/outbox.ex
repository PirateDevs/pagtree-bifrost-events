defmodule Bifrost.Outbox do
  @moduledoc ~S"""
  Outgoing events to Bifrost.
  """

  use Ecto.Schema

  import Ecto.Query

  @primary_key {:id, :id, autogenerate: true}
  schema "bifrost_outbox" do
    field :type, Ecto.Enum, values: Bifrost.Event.meta(:types)
    field :merchant_id, :string
    field :env_type, Ecto.Enum, values: Bifrost.Event.meta(:envs)
    field :subject_id, :string
    field :payload, :map
    field :timestamp, :utc_datetime_usec
  end

  @doc ~S"""
  Query builder.
  """
  def query(filters)
      when is_list(filters)
      when is_non_struct_map(filters) do
    Enum.reduce(filters, __MODULE__, fn
      {:merchant_id, id}, query -> where(query, [rec], rec.merchant_id == ^id)
      {:after, cursor}, query -> where(query, [rec], rec.id > ^cursor)
      {:take, n}, query -> limit(query, ^n)
    end)
  end
end
