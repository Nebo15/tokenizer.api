defmodule Tokenizer.DB.Models.RecipientPeer do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :type, :string
    field :phone, :string
    field :email, :string
    embeds_one :card, Tokenizer.DB.Models.RecipientCard
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:type, :phone, :email])
    |> cast_embed(:card)
    |> validate_required([:card, :phone])
    |> validate_inclusion(:type, ["card"], message: "Must be a card")
    |> validate_format(:email, ~r/(?:[a-z0-9!#$%&'*+\/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+\/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])/, message: "is invalid")
    |> validate_format(:phone, ~r/^\+380[0-9]{9}$/, message: "is invalid")
  end
end
