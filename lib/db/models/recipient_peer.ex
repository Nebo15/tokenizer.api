defmodule Tokenizer.DB.Models.RecipientPeer do
  use Tokenizer.Web, :model

  @primary_key false
  embedded_schema do
    field :type, Tokenizer.DB.Enums.PeerTypes
    field :phone, :string
    field :email, :string
    embeds_one :card, Tokenizer.DB.Models.RecipientCard
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:type, :phone, :email])
    |> validate_required([:type, :phone, :card])
    |> cast_embed(:card)
    |> validate_email(:email)
    |> validate_phone_number(:phone)
  end
end
