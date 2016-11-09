defmodule Tokenizer.DB.Schemas.Claim do
  @moduledoc """
  Model for transfers.
  """
  use Tokenizer.Web, :schema
  import Tokenizer.DB.Changeset.DynamicEmbeds
  import Tokenizer.DB.Changeset.Validators.EmbedType

  schema "claims" do
    field :external_id, :string
    field :status, Tokenizer.DB.Enums.TransferStatuses, default: :authorization
    field :token, :string
    field :token_expires_at, :utc_datetime
    field :credential, Tokenizer.DB.Types.PeerCredential
    field :auth, :map, default: %{type: "otp-code"}
    has_one :transfer, Tokenizer.DB.Schemas.Transfer
    field :metadata, :map

    timestamps()
  end

  def insert(%Ecto.Changeset{} = changeset) do
    changeset
    |> Ecto.Changeset.apply_changes()
    |> Tokenizer.DB.Repo.insert
  end

  def insert(%Tokenizer.DB.Schemas.Transfer{} = struct) do
    struct
    |> Tokenizer.DB.Repo.insert
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
end
