defmodule Tokenizer.DB.Models.CardToken do
  @moduledoc """
  Model for sender cards.
  """
  use Tokenizer.Web, :model

  @primary_key false
  embedded_schema do
    field :type, Tokenizer.DB.Enums.AccountCredential, default: "card-token"
    field :token, :string
    field :token_expires_at, Timex.Ecto.DateTime
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:token, :token_expires_at])
    |> validate_required([:token, :token_expires_at])
  end
end
