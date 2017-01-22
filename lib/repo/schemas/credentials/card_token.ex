defmodule Repo.Schemas.CardToken do
  @moduledoc """
  Schema for sender cards.
  """
  use API.Web, :schema
  import Repo.Changeset.Validators.TokenExpiration

  @primary_key false
  embedded_schema do
    field :type, :string, default: "card-token"
    field :token, :string
    field :token_expires_at, :utc_datetime
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:token, :token_expires_at])
    |> validate_required([:token])
    |> validate_token_expiration(:token_expires_at)
  end
end
