defmodule Mbill.Repo.Migrations.CreateTransfer do
  use Ecto.Migration

  def change do
    create table(:transfers) do
      add :external_id, :string
      add :token, :string
      add :token_expires_at, :utc_datetime
      add :amount, :decimal, precision: 19, scale: 2
      add :fee, :decimal, precision: 19, scale: 2
      add :description, :string
      add :status, :string
      add :auth, :map
      add :metadata, :map
      add :sender, :map
      add :recipient, :map

      timestamps()
    end

    create unique_index(:transfers, [:external_id])
    create unique_index(:transfers, [:token])
  end
end
