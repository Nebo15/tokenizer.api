defmodule Tokenizer.Views.Payment do
  @moduledoc """
  View for Payment controller.
  """

  use Tokenizer.Web, :view

  def render("payment.json", %{payment: payment}) do
    %{id: payment.id,
      external_id: payment.external_id,
      token: payment.token,
      token_expires_at: payment.token_expires_at,
      amount: payment.amount,
      fee: payment.fee,
      description: payment.description,
      status: payment.status,
      auth: payment.auth,
      metadata: payment.metadata,
      sender: render_one(payment.sender, Tokenizer.Views.Payment, "peer.json", as: :peer),
      recipient: render_one(payment.recipient, Tokenizer.Views.Payment, "peer.json", as: :peer),
      created_at: payment.inserted_at,
      updated_at: payment.updated_at}
  end

  def render("peer.json", %{peer: peer}) do
    %{type: peer.type,
      phone: peer.phone,
      email: peer.email,
      card: render_one(peer.card, Tokenizer.Views.Payment, "card.json", as: :card)}
  end

  def render("card.json", %{card: %{number: number}}) do
    %{number: String.slice(number, 1..6) <> String.duplicate("*", 6) <> String.slice(number, -4..-1)}
  end
end
