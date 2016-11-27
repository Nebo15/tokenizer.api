defmodule Tokenizer.Repo.Migrations.Claims do
  use Ecto.Migration

  def change do
    create table(:claims, primary_key: false) do
      add :id, :string, primary_key: true
      add :external_id, :string
      add :status, :string
      add :token, :string
      add :token_expires_at, :utc_datetime
      add :credential, :map
      add :auth, :map
      add :decline, :map
      add :transfer_id, references(:transfers)
      add :metadata, :map

      timestamps()
    end

    create unique_index(:claims, [:token])
  end
end
