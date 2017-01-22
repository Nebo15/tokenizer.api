defmodule Repo.Schemas.Claim do
  @moduledoc """
  Schema for transfers.
  """
  use API.Web, :schema
  import Repo.Changeset.DynamicEmbeds
  import Repo.Changeset.Validators.EmbedType

  schema "claims" do
    field :external_id, :string
    field :status, :string, default: "authentication"
    field :token, :string
    field :token_expires_at, :utc_datetime
    field :credential, Repo.Types.PeerCredential
    field :auth, :map, default: %{type: "otp-code"}
    belongs_to :transfer, Repo.Schemas.Transfer
    field :metadata, :map
    field :decline, :map

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:metadata, :external_id])
    |> cast_dynamic_embed(:credential)
    |> validate_required([:credential])
    |> validate_metadata(:metadata)
    |> unique_constraint(:token, name: :claims_token_index)
    |> foreign_key_constraint(:transfer_id)
    |> validate_inclusion(:status, ["authentication", "completed", "processing", "declined"])
    |> validate_embed_type(:credential, ["card-number"])
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
