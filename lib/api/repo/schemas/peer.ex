defmodule API.Repo.Schemas.Peer do
  @moduledoc """
  Model for transfer senders.
  """
  use API.Web, :schema
  import API.Repo.Changeset.DynamicEmbeds
  import API.Repo.Changeset.Validators.EmbedType

  @primary_key false
  embedded_schema do
    field :phone, :string
    field :email, :string
    field :credential, API.Repo.Types.PeerCredential
  end

  def sender_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:phone, :email])
    |> cast_dynamic_embed(:credential)
    |> validate_required([:credential])
    |> validate_email(:email)
    |> validate_phone_number(:phone)
    |> validate_embed_type(:credential, ["card", "card-token"])
  end

  def recipient_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:phone, :email])
    |> cast_dynamic_embed(:credential)
    |> validate_required([:credential])
    |> validate_email(:email)
    |> validate_phone_number(:phone)
    |> validate_embed_type(:credential, ["card-number", "card-token", "external-credential"])
  end
end
