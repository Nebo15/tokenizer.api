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
    field :credential, Tokenizer.DB.Types.AccountCredential
  end

  # Sender should have card or card token, but can't have card!
  def sender_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:phone, :email])
    |> cast_dynamic_embed(:credential)
    |> validate_required([:credential])
    |> validate_email(:email)
    |> validate_phone_number(:phone) # TODO: dump does not work, so changeset is trying to be written to DB
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
