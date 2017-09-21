defmodule Repo.Schemas.Transfer do
  @moduledoc """
  Schema for transfers.
  """
  use API.Web, :schema
  import Repo.Changeset.DynamicEmbeds
  import Repo.Changeset.Validators.Fee

  schema "transfers" do
    field :external_id, :string
    field :token, :string
    field :token_expires_at, :utc_datetime
    field :amount, :decimal
    field :fee, :decimal
    field :description, :string
    field :status, :string, default: "authentication"
    field :auth, Repo.Types.Authorization
    field :metadata, :map
    field :decline, :map
    embeds_one :sender, Repo.Schemas.Peer
    embeds_one :recipient, Repo.Schemas.Peer

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    limits = Confex.get(:gateway_api, :limits)
    fees = Confex.get(:gateway_api, :fees)

    struct
    |> cast(params, [:amount, :fee, :description, :metadata])
    |> cast_dynamic_embed(:auth)
    |> cast_embed(:sender, with: &Repo.Schemas.Peer.sender_changeset/2)
    |> cast_embed(:recipient, with: &Repo.Schemas.Peer.recipient_changeset/2)
    |> validate_required([:amount, :fee, :sender, :recipient])
    |> validate_number(:amount,
        greater_than_or_equal_to: limits[:amount][:min],
        less_than_or_equal_to: limits[:amount][:max])
    |> validate_number(:fee, greater_than: 0)
    |> validate_length(:description, max: 1024)
    |> validate_fee(:amount, :fee, fees)
    |> validate_metadata(:metadata)
    |> validate_inclusion(:status, ["authentication", "completed", "processing", "declined", "error"])
    |> unique_constraint(:external_id, name: :transfers_external_id_index)
  end

  def insert(%Ecto.Changeset{} = changeset) do
    changeset
    |> Ecto.Changeset.apply_changes()
    |> Repo.insert
  end

  def insert(%Repo.Schemas.Transfer{} = struct) do
    struct
    |> Repo.insert
  end

  def update(%Ecto.Changeset{} = changeset) do
    changeset
    |> Repo.update
  end
end
