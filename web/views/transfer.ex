defmodule Tokenizer.Views.Transfer do
  @moduledoc """
  View for Transfer controller.
  """

  use Tokenizer.Web, :view

  def render("transfer.json", %{transfer: transfer}) do
    %{id: transfer.id,
      external_id: transfer.external_id,
      token: transfer.token,
      token_expires_at: transfer.token_expires_at,
      amount: transfer.amount,
      fee: transfer.fee,
      description: transfer.description,
      status: transfer.status,
      auth: transfer.auth,
      metadata: transfer.metadata,
      sender: render_one(transfer.sender, Tokenizer.Views.Transfer, "peer.json", as: :peer),
      recipient: render_one(transfer.recipient, Tokenizer.Views.Transfer, "peer.json", as: :peer),
      created_at: transfer.inserted_at,
      updated_at: transfer.updated_at}
  end

  def render("peer.json", %{peer: peer}) do
    %{phone: peer.phone,
      email: peer.email,
      credential: render_one(peer.credential, Tokenizer.Views.Transfer, "credential.json", as: :credential)}
  end

  def render("credential.json", %{credential: %{type: type, number: number}}) when type in ["card", "card-number"] do
    %{type: type,
      number: hide_card_number(number)}
  end

  def render("credential.json", %{credential: %{type: type, id: id, metadata: metadata}})
      when type in ["external-credential"] do
    %{type: type,
      id: id,
      metadata: metadata}
  end

  defp hide_card_number(card_number) do
    String.slice(card_number, 1..6) <> String.duplicate("*", 6) <> String.slice(card_number, -4..-1)
  end
end
