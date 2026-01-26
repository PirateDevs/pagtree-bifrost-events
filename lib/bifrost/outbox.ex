defmodule Bifrost.Outbox do
  @moduledoc ~S"""
  Outgoing events to Bifrost.
  """

  use Bifrost.Model

  @primary_key {:id, :id, autogenerate: true}
  schema "bifrost_outbox" do
    field :type, Ecto.Enum, values: Bifrost.Event.meta(:types)
    field :merchant_id, :string
    field :env_type, Ecto.Enum, values: Bifrost.Event.meta(:envs)
    field :subject_id, :string
    field :payload, :map
    field :timestamp, :utc_datetime_usec
  end
end
