defmodule API.Repo.Schemas.Claim do
  @moduledoc """
  Schema for transfers.
  """
  use API.Web, :schema
  import API.Repo.Changeset.DynamicEmbeds
  import API.Repo.Changeset.Validators.EmbedType

  schema "claims" do
    field :external_id, :string
    field :status, API.Repo.Enums.TransferStatuses, default: :authorization
    field :token, :string
    field :token_expires_at, :utc_datetime
    field :credential, API.Repo.Types.PeerCredential
    field :auth, :map, default: %{type: "otp-code"}
    has_one :transfer, API.Repo.Schemas.Transfer
    field :metadata, :map

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:metadata, :external_id])
    |> cast_dynamic_embed(:credential)
    |> validate_required([:credential, :external_id])
    |> validate_metadata(:metadata)
    |> validate_embed_type(:credential, ["card-number"])
    |> unique_constraint(:token, name: :claims_token_index)
  end

  def insert(%Ecto.Changeset{} = changeset) do
    changeset
    |> Ecto.Changeset.apply_changes()
    |> API.Repo.insert
  end

  def insert(%API.Repo.Schemas.Transfer{} = struct) do
    struct
    |> API.Repo.insert
  end

  def update(%Ecto.Changeset{} = changeset) do
    changeset
    |> API.Repo.update
  end
end
