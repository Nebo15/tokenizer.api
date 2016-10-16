defmodule Tokenizer.Controllers.Card do
  @moduledoc """
  Controller for `/cards` API requests.
  """

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
end
