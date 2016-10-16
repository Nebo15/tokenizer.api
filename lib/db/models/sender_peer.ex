defmodule Tokenizer.DB.Models.SenderPeer do
  use Tokenizer.Web, :model
  alias Tokenizer.DB.Models.Card, as: Card

  embedded_schema do
    field :type, :string
    field :phone, :string
    field :email, :string
    embeds_one :card, Card
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:type, :phone, :email])
    |> cast_embed(:card)
    |> validate_required([:type, :phone, :email, :card])
    |> validate_inclusion(:type, ["card"], message: "Must be a card")
    |> validate_format(:email, ~r/(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)/, message: "Invalid email")
  end
end
