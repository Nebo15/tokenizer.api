defmodule Tokenizer.Controllers.Transfer do
  @moduledoc """
  This controller implements REST API to send different kins of transfers and fetch information about them.
  """
  use Tokenizer.Web, :controller

  alias Tokenizer.DB.Schemas.Transfer, as: TransferSchema
  alias Tokenizer.Views.Transfer, as: TransferView
  alias Tokenizer.CardStorage.Supervisor, as: CardStorage
  alias Tokenizer.DB.Repo

  @transfer_token_prefix "transfer-token"

  # Actions

  @doc """
  POST /transfers
  """
  def create(conn, params) when is_map(params) do
    %TransferSchema{}
    |> TransferSchema.changeset(params)
    |> resolve_credential_token
    |> get_transfer_autorization
    |> put_transfer_token
    |> save_transfer
    |> send_response(:created, conn)
  end

  # Transfer Gateway delegates
  # TODO: resolve recipients token
  defp resolve_credential_token(%Ecto.Changeset{valid?: false} = changeset), do: {:error, :invalid, changeset}
  defp resolve_credential_token(%Ecto.Changeset{valid?: true, changes: %{sender: %{
                                                                changes: %{credential: %{
                                                                  changes: %{token: token},
                                                                  data: %{type: "card-token"}} = credential}
                                                                } = sender}} = changeset) do
    case CardStorage.get_card(token) do
      {:ok, card_data} ->
        sender = sender
        |> Ecto.Changeset.put_embed(:credential, card_data)

        changeset = changeset
        |> Ecto.Changeset.put_embed(:sender, sender)

        {:ok, changeset}
      {:error, _} ->
        credential = credential
        |> Ecto.Changeset.add_error(:token, "is invalid", validation: :token)

        sender = sender
        |> Ecto.Changeset.put_embed(:credential, credential)

        changeset = changeset
        |> Ecto.Changeset.put_embed(:sender, sender)

        {:error, :invalid, changeset}
    end
  end
  defp resolve_credential_token(%Ecto.Changeset{valid?: true, changes: %{sender: %{
                                                                changes: %{credential: %{
                                                                  data: %{type: _}}}}}} = changeset) do
    {:ok, changeset}
  end

  defp get_transfer_autorization({:error, reason, details}), do: {:error, reason, details}
  defp get_transfer_autorization({:ok, %Ecto.Changeset{} = changeset}) do
    external_id = 10000
    |> :rand.uniform()
    |> to_string

    changeset = changeset
    |> Ecto.Changeset.put_change(:auth, %Tokenizer.DB.Schemas.Authorization3DS{})
    |> Ecto.Changeset.put_change(:external_id, external_id)

    {:ok, changeset}
  end

  defp put_transfer_token({:error, reason, details}), do: {:error, reason, details}
  defp put_transfer_token({:ok, %Ecto.Changeset{} = changeset}) do
    expires_in = Confex.get(:tokenizer_api, :transfer_token_expires_in)

    expires_at = Timex.now
    |> Timex.shift(microseconds: expires_in)

    {:ok, changeset
          |> Ecto.Changeset.put_change(:token, @transfer_token_prefix <> "-" <> Ecto.UUID.generate)
          |> Ecto.Changeset.put_change(:token_expires_at, expires_at)}
  end

  # Store transfer changes into DB
  defp save_transfer({:error, reason, details}), do: {:error, reason, details}
  defp save_transfer({:ok, %Ecto.Changeset{valid?: false} = changeset}), do: {:error, :invalid, changeset}
  defp save_transfer({:ok, %Ecto.Changeset{valid?: true} = changeset}) do
    changeset
    |> TransferSchema.insert
  end

  @doc """
  GET /transfers/:id?token=token
  """
  def show(%Plug.Conn{assigns: %{transfer_token: token}} = conn, %{"id" => id}) do
    TransferSchema
    |> Repo.get_by(id: id)
    |> check_query_result
    |> validate_token(token)
    # |> update_transfer_status TODO: get transfer status and persist it
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
