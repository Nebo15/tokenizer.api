defmodule Tokenizer.DB.Schemas.CardNumber do
  @moduledoc """
  Model for sender cards.
  """
  use Tokenizer.Web, :schema

  @primary_key false
  embedded_schema do
    field :type, Tokenizer.DB.Enums.AccountCredential, default: "card-number"
    field :number, :string
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:number])
    |> validate_required([:number])
    |> validate_card_number(:number)
  end
end
