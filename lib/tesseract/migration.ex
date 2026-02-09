defmodule Tesseract.Migration do
  @moduledoc ~S"""
  Tesseract's Ecto migrations.
  """

  @doc false
  defmacro up(1) do
    quote do
      # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
      #                            INBOX                            #
      # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

      create table(:tesseract_inbox, primary_key: false) do
        add :id, :integer, primary_key: true
        add :type, :string, size: 64, null: false
        add :merchant_id, :string, size: 36, null: false
        add :env_type, :string, size: 8, null: false
        add :subject_id, :string, size: 36, null: false
        add :payload, :json, null: false
        add :timestamp, :utc_datetime_usec, null: false
      end

      # prevent duplicated events
      create unique_index(:tesseract_inbox, [:subject_id, :type])

      # for streaming events that belong to a specific merchant
      create index(:tesseract_inbox, [:merchant_id, "id ASC"])

      # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
      #                           OUTBOX                            #
      # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

      create table(:tesseract_outbox, primary_key: false) do
        add :id, :id, primary_key: true
        add :type, :string, size: 64, null: false
        add :merchant_id, :string, size: 36, null: false
        add :env_type, :string, size: 8, null: false
        add :subject_id, :string, size: 36, null: false
        add :payload, :json, null: false
        add :timestamp, :utc_datetime_usec, null: false
      end

      # prevent duplicated events
      create unique_index(:tesseract_outbox, [:subject_id, :type])

      # for streaming events that belong to a specific merchant
      create index(:tesseract_outbox, [:merchant_id, "id ASC"])
    end
  end

  @doc false
  defmacro down(1) do
    quote do
      drop_if_exists index(:tesseract_outbox, [:merchant_id, "id ASC"])
      drop_if_exists unique_index(:tesseract_outbox, [:subject_id, :type])
      drop_if_exists table(:tesseract_outbox)

      drop_if_exists index(:tesseract_inbox, [:merchant_id, "id ASC"])
      drop_if_exists unique_index(:tesseract_inbox, [:subject_id, :type])
      drop_if_exists table(:tesseract_inbox)
    end
  end
end
