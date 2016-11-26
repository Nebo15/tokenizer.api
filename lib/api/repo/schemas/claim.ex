defmodule API.Repo.Schemas.Claim do
  @moduledoc """
  Schema for transfers.
  """
  use API.Web, :schema
  import API.Repo.Changeset.DynamicEmbeds
  import API.Repo.Changeset.Validators.EmbedType

  @primary_key {:id, :string, []}
  schema "claims" do
    field :external_id, :string
    field :status, API.Repo.Enums.ClaimStatuses, default: :authentication
    field :token, :string
    field :token_expires_at, :utc_datetime
    field :credential, API.Repo.Types.PeerCredential
    field :auth, :map, default: %{type: "otp-code"}
    belongs_to :transfer, API.Repo.Schemas.Transfer
    field :metadata, :map

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:metadata, :external_id, :id])
    |> cast_dynamic_embed(:credential)
    |> validate_required([:credential])
    |> validate_metadata(:metadata)
    |> unique_constraint(:token, name: :claims_token_index)
    |> foreign_key_constraint(:transfer_id)
    |> validate_embed_type(:credential, ["card-number"])
  end

  def insert(%Ecto.Changeset{} = changeset) do
    changeset
    |> Ecto.Changeset.apply_changes()
    |> Repo.insert
  end

  def insert(%API.Repo.Schemas.Transfer{} = struct) do
    struct
    |> Repo.insert
  end

  def update(%Ecto.Changeset{} = changeset) do
    changeset
    |> Repo.update
  end
end
