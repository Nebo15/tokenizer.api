defmodule Tokenizer.DB.Models.Payment do
  use Tokenizer.Web, :model

  schema "payments" do
    field :external_id, :string
    field :token, :string
    field :token_expires_at, Ecto.DateTime
    field :amount, :float
    field :fee, :float
    field :description, :string
    field :status, Tokenizer.DB.Enums.PaymentStatuses
    field :auth, :map
    embeds_one :sender, Tokenizer.DB.Models.SenderPeer
    embeds_one :recipient, Tokenizer.DB.Models.RecipientPeer

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:amount, :fee, :description, :status, :auth, :external_id, :token, :token_expires_at])
    |> validate_required([:amount, :fee, :status, :auth, :external_id, :token, :token_expires_at, :sender, :recipient])
    |> cast_embed(:sender)
    |> cast_embed(:recipient)
    |> validate_number(:amount, greater_than_or_equal_to: 1, less_than_or_equal_to: 10000)
    |> validate_number(:fee, greater_than_or_equal_to: 1, less_than_or_equal_to: 1000)
    |> validate_length(:description, min: 2, max: 250)
    |> unique_constraint(:external_id)
    |> unique_constraint(:token)
  end
end
