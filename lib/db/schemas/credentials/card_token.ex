defmodule Tokenizer.DB.Schemas.CardToken do
  @moduledoc """
  Model for sender cards.
  """
  use Tokenizer.Web, :schema
  import Tokenizer.DB.Changeset.Validators.Expiration

  @primary_key false
  embedded_schema do
    field :type, Tokenizer.DB.Enums.AccountCredential, default: "card-token"
    field :token, :string
    field :token_expires_at, :utc_datetime
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:token, :token_expires_at])
    |> validate_required([:token])
    |> validate_expiration(:token_expires_at)
  end
end
