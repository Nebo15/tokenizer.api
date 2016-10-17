defmodule Tokenizer.Controllers.Card do
  @moduledoc """
  Controller for `/cards` API requests.
  """

  use Tokenizer.Web, :controller
  alias Tokenizer.DB.Models.SenderCard
  alias Tokenizer.Views.Card, as: CardView
  alias Tokenizer.CardStorage.Supervisor, as: CardStorage

  # Actions
  def create(conn, params) when is_map(params) do
    %SenderCard{}
    |> SenderCard.changeset(params)
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

  defp send_response({:ok, %{token: _, token_expires_at: _} = card}, conn) do
    conn
    |> put_status(:created)
    |> render(CardView, "card.json", card: card)
  end

  defp send_response({:error, :invalid, %Ecto.Changeset{} = changeset}, conn) do
    conn
    |> put_status(422)
    |> render(EView.ValidationErrorView, "422.json", changeset)
  end
end
