defmodule Tokenizer.Views.Payment do
  @moduledoc """
  View for Payment controller.
  """

  use Tokenizer.Web, :view

  def render("payment.json", %{payment: payment}) do
    %{id: payment.id,
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
    %{phone: peer.phone,
      email: peer.email,
      credential: render_one(peer.credential, Tokenizer.Views.Payment, "credential.json", as: :credential)}
  end

  def render("credential.json", %{credential: %{type: type, number: number}}) when type in ["card", "card-number"] do
    %{type: type,
      number: hide_card_number(number)}
  end

  defp hide_card_number(card_number) do
    String.slice(card_number, 1..6) <> String.duplicate("*", 6) <> String.slice(card_number, -4..-1)
  end
end
