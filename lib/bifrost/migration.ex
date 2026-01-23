defmodule Bifrost.Migration do
  @moduledoc ~S"""
  Bifrost's Ecto migrations.
  """

  @doc false
  defmacro up(1) do
    quote do
      create table(:bifrost_outbox, primary_key: false) do
        add :id, :id, primary_key: true
        add :type, :string, null: false
        add :merchant_id, :string, null: false
        add :env_type, :string, null: false
        add :subject_id, :string, null: false
        add :payload, :json, null: false
        add :timestamp, :utc_datetime_usec, null: false
      end

      # for streaming events that belong to a specific merchant
      create index(:bifrost_outbox, [:merchant_id, "id ASC"])

      create table(:bifrost_inbox, primary_key: false) do
        add :id, :bigserial, primary_key: true
        add :type, :string, null: false
        add :merchant_id, :string, null: false
        add :env_type, :string, null: false
        add :subject_id, :string, null: false
        add :payload, :json, null: false
        add :timestamp, :utc_datetime_usec, null: false
      end

      # for streaming events that belong to a specific merchant
      create index(:bifrost_inbox, [:merchant_id, "id ASC"])
    end
  end

  @doc false
  defmacro down(1) do
    quote do
      drop_if_exists index(:bifrost_inbox, [:merchant_id, "id ASC"])
      drop_if_exists table(:bifrost_inbox)
      drop_if_exists index(:bifrost_outbox, [:merchant_id, "id ASC"])
      drop_if_exists table(:bifrost_outbox)
    end
  end
end
