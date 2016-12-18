defmodule API.Repo.Schemas.Peer do
  @moduledoc """
  Schema for transfer senders.
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

  def recipient_changeset(struct, params \\ %{})

  # Recipient with external credential must have :phone
  def recipient_changeset(struct, %{"credential" => %{"type" => "external-credential"}} = params) do
    struct
    |> apply_recipient_changeset(params)
    |> validate_required([:phone])
  end

  # Other types
  def recipient_changeset(struct, params) do
    struct
    |> apply_recipient_changeset(params)
  end

  defp apply_recipient_changeset(struct, params) do
    struct
    |> cast(params, [:phone, :email])
    |> cast_dynamic_embed(:credential)
    |> validate_required([:credential])
    |> validate_email(:email)
    |> validate_phone_number(:phone)
    |> validate_embed_type(:credential, ["card-number", "card-token", "external-credential"])
  end
end
