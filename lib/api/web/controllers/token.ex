defmodule API.Controllers.Token do
  @moduledoc """
  Controller for `/tokens` API requests.
  """
  use API.Web, :controller
  alias API.Repo.Schemas.Card, as: CardModel
  alias API.Repo.Schemas.CardToken, as: CardTokenModel
  alias API.Views.Token, as: TokenView
  alias Tokenizer.Supervisor, as: CardStorage

  @doc """
  POST /tokens
  """
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
    |> render(EView.Views.ValidationError, "422.json", changeset)
  end
end
