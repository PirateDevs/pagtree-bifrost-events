defmodule Bifrost.Inbox do
  @moduledoc ~S"""
  Incomming events from Bifrost.
  """

  use Bifrost.Model

  @primary_key {:id, :id, []}
  schema "bifrost_inbox" do
    field :type, Ecto.Enum, values: Bifrost.Event.meta(:types)
    field :merchant_id, :string
    field :env_type, Ecto.Enum, values: Bifrost.Event.meta(:envs)
    field :subject_id, :string
    field :payload, :map
    field :timestamp, :utc_datetime_usec
  end
end
