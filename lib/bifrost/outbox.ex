defmodule Bifrost.Outbox do
  @moduledoc ~S"""
  Outgoing events to Bifrost.
  """

  use Bifrost.Model

  import Ecto.Changeset

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

  @doc false
  def changeset(%Bifrost.Outbox{} = record \\ %Bifrost.Outbox{}, %{} = params) do
    record
    |> cast(params, [:type, :merchant_id, :env_type, :subject_id, :payload, :timestamp])
    |> validate_required([:type, :merchant_id, :env_type, :subject_id, :payload])
    |> validate_inclusion(:type, @types)
    |> validate_inclusion(:env_type, @envs)
  end
end
