defmodule Mbill.Repo.Migrations.CreatePayment do
  use Ecto.Migration

  def change do
    create table(:payments) do
      add :external_id, :string
      add :token, :string
      add :token_expires_at, :datetime
      add :amount, :float
      add :fee, :float
      add :description, :string
      add :status, :string
      add :auth, :map
      add :sender, :map
      add :recipient, :map

      timestamps()
    end

    create unique_index(:payments, [:external_id])
    create unique_index(:payments, [:token])
  end
end
