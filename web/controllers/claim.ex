defmodule Tokenizer.Controllers.Claim do
  @moduledoc """
  Controller for transfer claim entity.
  """
  use Tokenizer.Web, :controller

  alias Tokenizer.DB.Schemas.Transfer, as: TransferSchema
  alias Tokenizer.Views.Transfer, as: TransferView
  alias Tokenizer.CardStorage.Supervisor, as: CardStorage
  alias Tokenizer.DB.Repo

  # Actions
  @doc """
  GET /transfers/:id?token=token
  """
  def claim(conn, %{"id" => id, "token" => token}) do
    TransferSchema
    |> Repo.get_by(id: id)
    |> check_query_result
    |> validate_token(token)
    #|> update_transfer_status TODO: get transfer status and persist it
    |> send_response(:ok, conn)
  end

  defp check_query_result(nil), do: {:error, :not_found}
  defp check_query_result(%TransferSchema{} = transfer), do: {:ok, transfer}

  defp validate_token({:error, reason}, _), do: {:error, reason}
  defp validate_token({:ok, %{token: transfer_token} = transfer}, user_token) when transfer_token == user_token do
    {:ok, transfer}
  end

  defp validate_token({:ok, _}, _) do
    {:error, :access_denied}
  end

  # Store transfer changes into DB
  defp save_transfer({:error, reason, details}), do: {:error, reason, details}
  defp save_transfer({:ok, %Ecto.Changeset{valid?: false} = changeset}), do: {:error, :invalid, changeset}
  defp save_transfer({:ok, %Ecto.Changeset{valid?: true} = changeset}) do
    changeset
    |> TransferSchema.insert
  end

  # Responses
  defp send_response({:ok, %TransferSchema{} = transfer}, status, conn) do
    conn
    |> put_status(status)
    |> render(TransferView, "transfer.json", transfer: transfer)
  end

  defp send_response({:error, :invalid, %Ecto.Changeset{} = changeset}, _, conn) do
    conn
    |> put_status(422)
    |> render(EView.ValidationErrorView, "422.json", changeset)
  end

  defp send_response({:error, :not_found}, _, conn) do
    conn
    |> put_status(404)
    |> render(EView.ErrorView, "404.json", %{})
  end

  defp send_response({:error, :access_denied}, _, conn) do
    conn
    |> put_status(401)
    |> render(EView.ErrorView, "401.json", %{})
  end
end
