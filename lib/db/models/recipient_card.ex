defmodule Tokenizer.DB.Models.RecipientCard do
  @moduledoc """
  Model for recipient cards.
  """
  use Tokenizer.Web, :model

  @primary_key false
  embedded_schema do
    field :number, :string
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:number])
    |> validate_required([:number])
    |> validate_card_number(:number)
  end
end
