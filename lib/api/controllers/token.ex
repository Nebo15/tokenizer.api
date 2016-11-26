defmodule API.Controllers.Token do
  @moduledoc """
  Controller for `/tokens` API requests.
  """
  use API.Web, :controller
  alias API.Repo.Schemas.Card, as: CardSchema
  alias API.Repo.Schemas.CardToken, as: CardTokenSchema
  alias API.Views.Token, as: TokenView
  alias Tokenizer.Supervisor, as: Tokenizer

  @doc """
  POST /tokens
  """
  def create(conn, params) when is_map(params) do
    %CardSchema{}
    |> CardSchema.changeset(params)
    |> save_card
    |> send_response(conn)
  end

  defp save_card(%Ecto.Changeset{valid?: false} = changeset) do
    {:error, changeset}
  end

  defp save_card(%Ecto.Changeset{valid?: true} = changeset) do
    changeset
    |> Ecto.Changeset.apply_changes
    |> Tokenizer.save_card
  end

  defp send_response({:ok, %CardTokenSchema{} = card}, conn) do
    conn
    |> put_status(:created)
    |> render(TokenView, "card.json", card: card)
  end

  defp send_response({:error, %Ecto.Changeset{} = changeset}, conn) do
    conn
    |> put_status(422)
    |> render(EView.Views.ValidationError, "422.json", changeset)
  end
end
