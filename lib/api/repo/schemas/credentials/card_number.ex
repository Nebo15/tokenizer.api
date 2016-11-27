defmodule API.Repo.Schemas.CardNumber do
  @moduledoc """
  Schema for sender cards.
  """
  use API.Web, :schema

  @primary_key false
  embedded_schema do
    field :type, :string, default: "card-number"
    field :number, :string
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:number])
    |> validate_required([:number])
    |> validate_card_number(:number)
  end
end
