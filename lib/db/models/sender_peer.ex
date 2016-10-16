defmodule Tokenizer.DB.Models.SenderPeer do
  @moduledoc """
  Model for transfer senders.
  """
  use Tokenizer.Web, :model

  @primary_key false
  embedded_schema do
    field :type, Tokenizer.DB.Enums.PeerTypes
    field :phone, :string
    field :email, :string
    embeds_one :card, Tokenizer.DB.Models.SenderCard
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:type, :phone, :email])
    |> cast_embed(:card)
    |> validate_required([:type, :phone, :card])
    |> validate_email(:email)
    |> validate_phone_number(:phone)
  end
end
