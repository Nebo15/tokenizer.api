defmodule Tokenizer.Views.Payment do
  @moduledoc """
  View for Payment controller.
  """

  use Tokenizer.Web, :view

  def render("payment.json", _assigns) do
    %{page: %{detail: "This is page."}}
  end

  # def render("index.json", %{payments: payments}) do
  #   %{data: render_many(payments, Payment, "payment.json")}
  # end

  # def render("show.json", %{payment: payment}) do
  #   %{data: render_one(payment, Payment, "payment.json")}
  # end

  # def render("payment.json", %{payment: payment}) do
  #   %{id: payment.id,
  #     pay2you_id: payment.pay2you_id,
  #     fee: payment.fee,
  #     auth: payment.auth,
  #     amount: payment.amount,
  #     description: payment.description,
  #     status: payment.status,
  #     token: payment.token,
  #     token_expires: get_token_expiration(payment.inserted_at),
  #     created_at: payment.inserted_at,
  #     updated_at: payment.updated_at,
  #     sender: render_one(payment.sender, Payment, "cardholder.json"),
  #     recipient: render_one(payment.recipient, Payment, "cardholder.json"),
  #   }
  # end

  # def render("cardholder.json", %{payment: cardholder}) do
  #   %{email: cardholder.email,
  #     type: cardholder.type,
  #     phone: cardholder.phone,
  #     card: render_one(cardholder.card, Payment, "card.json"),
  #   }
  # end

  # def render("card.json", %{payment: card}) do
  #   %{number: card.number}
  # end

  # def get_token_expiration(inserted_at) do
  #   inserted_at
  #   |> Ecto.DateTime.to_erl()
  #   |> Timex.to_datetime("Etc/UTC")
  #   |> Timex.shift(seconds: Application.fetch_env!(:mbill, :token_ttl))
  # end
end
