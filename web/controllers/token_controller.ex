defmodule Tokenizer.Controllers.Token do
  @moduledoc """
  Controller for `/cards` API requests.
  """

  use Tokenizer.Web, :controller
  alias Tokenizer.DB.Models.Card, as: CardModel
  alias Tokenizer.DB.Models.CardToken, as: CardTokenModel
  alias Tokenizer.Views.Token, as: TokenView
  alias Tokenizer.CardStorage.Supervisor, as: CardStorage

  # Actions
  def create(conn, params) when is_map(params) do
    %CardModel{}
    |> CardModel.changeset(params)
    |> save_card
    |> send_response(conn)
  end

  defp save_card(%Ecto.Changeset{valid?: false} = changeset) do
    {:error, :invalid, changeset}
  end

  defp save_card(%Ecto.Changeset{valid?: true} = changeset) do
    changeset
    |> Ecto.Changeset.apply_changes
    |> CardStorage.save_card
  end

  defp send_response({:ok, %CardTokenModel{} = card}, conn) do
    conn
    |> put_status(:created)
    |> render(TokenView, "card.json", card: card)
  end

  defp send_response({:error, :invalid, %Ecto.Changeset{} = changeset}, conn) do
    conn
    |> put_status(422)
    |> render(EView.ValidationErrorView, "422.json", changeset)
  end
end
