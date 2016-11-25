defmodule Tokenizer.Repo.Migrations.Claims do
  use Ecto.Migration

  def change do
    create table(:claims) do
      add :external_id, :string
      add :status, :string
      add :token, :string
      add :token_expires_at, :utc_datetime
      add :credential, :map
      add :auth, :map
      add :transfer, references(:transfers)
      add :metadata, :map

      timestamps()
    end

    create unique_index(:claims, [:token])
  end
end
