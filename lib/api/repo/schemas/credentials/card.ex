defmodule API.Repo.Schemas.Card do
  @moduledoc """
  Schema for sender cards.
  """
  use API.Web, :schema

  @primary_key false
  embedded_schema do
    field :type, :string, default: "card"
    field :number, :string
    field :expiration_month, :integer
    field :expiration_year, :integer
    field :cvv, :string
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:number, :expiration_month, :expiration_year, :cvv])
    |> validate_required([:number, :expiration_month, :expiration_year, :cvv])
    |> validate_card_number(:number)
    |> validate_format(:cvv, ~r/^[0-9]{3,4}$/)
    |> validate_number(:expiration_month, greater_than_or_equal_to: 1, less_than_or_equal_to: 12)
    |> validate_number(:expiration_year, greater_than_or_equal_to: 2016, less_than_or_equal_to: 2030)
  end
end
