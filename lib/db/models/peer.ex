defmodule Tokenizer.DB.Models.Peer do
  @moduledoc """
  Model for transfer senders.
  """
  use Tokenizer.Web, :model
  import Tokenizer.DB.Changeset.DynamicEmbeds

  @primary_key false
  embedded_schema do
    field :phone, :string
    field :email, :string
    field :credential, Tokenizer.DB.Types.PeerCredential
  end

  # TODO: Sender should have card or card token, but can't have card!
  def sender_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:phone, :email])
    |> cast_dynamic_embed(:credential)
    |> validate_required([:credential])
    |> validate_email(:email)
    |> validate_phone_number(:phone)
  end

  def recipient_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:phone, :email])
    |> cast_dynamic_embed(:credential)
    |> validate_required([:credential])
    |> validate_email(:email)
    |> validate_phone_number(:phone)
  end
end
