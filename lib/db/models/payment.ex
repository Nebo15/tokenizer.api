defmodule Tokenizer.DB.Models.Payment do
  @moduledoc """
  Model for payments.
  """
  use Tokenizer.Web, :model
  import Tokenizer.DB.Changeset.DynamicEmbeds

  schema "payments" do
    field :external_id, :string
    field :token, :string
    field :token_expires_at, Timex.Ecto.DateTime
    field :amount, :decimal
    field :fee, :decimal
    field :description, :string
    field :status, Tokenizer.DB.Enums.PaymentStatuses, default: :authorization
    field :auth, Tokenizer.DB.Types.Authorization
    field :metadata, :map
    embeds_one :sender, Tokenizer.DB.Models.Peer
    embeds_one :recipient, Tokenizer.DB.Models.Peer

    timestamps()
  end

  def insert(%Ecto.Changeset{} = changeset) do
    changeset
    |> Ecto.Changeset.apply_changes()
    |> Tokenizer.DB.Repo.insert
  end

  def insert(%Tokenizer.DB.Models.Payment{} = struct) do
    struct
    |> Tokenizer.DB.Repo.insert
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.

  It should be used to validate data that is sent by API consumers,
  so we don't force them to send internally required fields.
  """
  def changeset(struct, params \\ %{}) do
    limits = Confex.get(:tokenizer_api, :limits)

    struct
    |> cast(params, [:amount, :fee, :description, :metadata])
    |> cast_dynamic_embed(:auth)
    |> cast_embed(:sender, with: &Tokenizer.DB.Models.Peer.sender_changeset/2)
    |> cast_embed(:recipient, with: &Tokenizer.DB.Models.Peer.recipient_changeset/2)
    |> validate_required([:amount, :fee, :description, :sender, :recipient])
    |> validate_number(:amount,
        greater_than_or_equal_to: limits[:amount][:min],
        less_than_or_equal_to: limits[:amount][:max])
    |> validate_number(:fee, greater_than: 0)
    |> validate_length(:description, max: 250)
    |> validate_metadata(:metadata)
  end
end
