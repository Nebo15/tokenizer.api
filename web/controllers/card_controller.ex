defmodule Tokenizer.Controllers.Card do
  use Tokenizer.Web, :controller
  alias Tokenizer.DB.Models.SenderCard
  alias Tokenizer.Views.Card
  alias Tokenizer.CardStorage.Supervisor, as: CardStorage

  # Actions
  def create(conn, params) do
    %SenderCard{}
    |> SenderCard.changeset(params)
    |> save_card
    |> send_response(conn)
  end

  defp save_card(%Ecto.Changeset{valid?: true} = changeset) do
    card = changeset
    |> Ecto.Changeset.apply_changes

    card
    |> CardStorage.save_card
  end

  defp save_card(%Ecto.Changeset{valid?: false} = changeset) do
    {:error, :invalid, changeset}
  end

  defp send_response({:ok, card}, conn) do
    conn
    |> put_status(:created)
    |> render(Card, "card.json", card: card)
  end

  defp send_response({:error, :invalid, changeset}, conn) do
    conn
    |> put_status(422)
    |> render(EView.ValidationErrorView, "422.json", changeset)
  end

  # Responses
  # defp send_response({:ok, payment}, conn) do
  #   conn
  #   |> put_status(:created)
  #   |> render("show.json", payment: payment)
  # end

  # defp send_response({:error, %{id: _, status: _, decline: _} = reason}, conn) do
  #   conn
  #   |> put_status(400)
  #   |> render(Mbill.ErrorView, "pay2you_400.json", errors: reason)
  # end

  # defp send_response({:error, %{pay2you: true, reason: reason}}, conn) do
  #   conn
  #   |> put_status(400)
  #   |> render(Mbill.ErrorView, "pay2you_400.json", errors: reason)
  # end

  # defp send_response({:error, {:validation, param, msg}}, conn) do
  #   conn
  #   |> put_status(422)
  #   |> render(Mbill.ErrorView, "422.json", %{param: param, msg: msg, type: "invalid_completion_code"})
  # end

  # defp send_response({:error, changeset: changeset}, conn) do
  #   conn
  #   |> put_status(422)
  #   |> render(Mbill.ErrorView, "422.json", %{changeset: changeset})
  # end

  # defp send_response({:error, reason}, conn) do
  #   conn
  #   |> put_status(400)
  #   |> render(Mbill.ErrorView, "400.json", errors: reason)
  # end
end
