defmodule Bifrost.Migration do
  @moduledoc ~S"""
  Bifrost's Ecto migrations.
  """

  @doc false
  defmacro up(1) do
    quote do
      # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
      #                            INBOX                            #
      # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

      create table(:bifrost_inbox, primary_key: false) do
        add :id, :integer, primary_key: true
        add :type, :string, size: 64, null: false
        add :merchant_id, :string, size: 36, null: false
        add :env_type, :string, size: 8, null: false
        add :subject_id, :string, size: 36, null: false
        add :payload, :json, null: false
        add :timestamp, :utc_datetime_usec, null: false
      end

      # prevent duplicated events
      create unique_index(:bifrost_inbox, [:subject_id, :type])

      # for streaming events that belong to a specific merchant
      create index(:bifrost_inbox, [:merchant_id, "id ASC"])

      # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
      #                           OUTBOX                            #
      # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

      create table(:bifrost_outbox, primary_key: false) do
        add :id, :identity, primary_key: true
        add :type, :string, size: 64, null: false
        add :merchant_id, :string, size: 36, null: false
        add :env_type, :string, size: 8, null: false
        add :subject_id, :string, size: 36, null: false
        add :payload, :json, null: false
        add :timestamp, :utc_datetime_usec, null: false
      end

      # prevent duplicated events
      create unique_index(:bifrost_outbox, [:subject_id, :type])

      # for streaming events that belong to a specific merchant
      create index(:bifrost_outbox, [:merchant_id, "id ASC"])
    end
  end

  @doc false
  defmacro down(1) do
    quote do
      drop_if_exists index(:bifrost_outbox, [:merchant_id, "id ASC"])
      drop_if_exists unique_index(:bifrost_outbox, [:subject_id, :type])
      drop_if_exists table(:bifrost_outbox)

      drop_if_exists index(:bifrost_inbox, [:merchant_id, "id ASC"])
      drop_if_exists unique_index(:bifrost_inbox, [:subject_id, :type])
      drop_if_exists table(:bifrost_inbox)
    end
  end
end
