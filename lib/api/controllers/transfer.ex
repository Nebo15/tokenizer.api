defmodule API.Controllers.Transfer do
  @moduledoc """
  This controller implements REST API to send different kins of transfers and fetch information about them.
  """
  use API.Web, :controller
  alias Processing.Adapters.Pay2You.Transfer, as: TransferService
  alias API.Repo.Schemas.Transfer, as: TransferSchema
  alias API.Repo.Schemas.Card, as: CardSchema
  alias API.Repo.Schemas.CardNumber, as: CardNumberSchema
  alias API.Repo.Schemas.AuthorizationLookupCode
  alias API.Views.Transfer, as: TransferView
  alias API.Helpers.TokenResolver
  alias API.Repo
  alias Ecto.Changeset

  @transfer_token_prefix "transfer-token"

  @doc """
  POST /transfers
  """
  def create(conn, params) when is_map(params) do
    %TransferSchema{}
    |> TransferSchema.changeset(params)
    |> TokenResolver.resolve_credentials(:sender)
    |> TokenResolver.resolve_credentials(:recipient)
    |> send_transfer()
    |> put_transfer_token()
    |> create_transfer()
    |> render_response(conn, :created)
  end

  # Transfer Gateway delegates
  defp send_transfer(%Changeset{valid?: false} = changeset), do: changeset
  defp send_transfer(%Changeset{valid?: true} = changeset) do
    update = changeset
    |> Changeset.apply_changes()
    |> do_send_transfer()

    changeset
    |> Changeset.change(update)
  end

  # Card2Card transfers
  defp do_send_transfer(%{amount: amount, fee: fee,
                          sender: %{credential: %CardSchema{} = sender_credential, phone: sender_phone},
                          recipient: %{credential: %CardNumberSchema{} = recipient_credential}}) do
    case TransferService.card2card(sender_credential, recipient_credential, amount, fee, sender_phone) do
      {:ok, update} -> update
      {:error, update} -> update
    end
  end

  defp do_send_transfer(_) do
    external_id = 10_000
    |> :rand.uniform()
    |> to_string

    %{
      auth: %API.Repo.Schemas.Authorization3DS{},
      external_id: external_id
    }
  end

  defp put_transfer_token(%Changeset{valid?: false} = changeset), do: changeset
  defp put_transfer_token(%Changeset{valid?: true} = changeset) do
    expires_in = Confex.get(:gateway_api, :transfer_token_expires_in)
    expires_at = Timex.now |> Timex.shift(microseconds: expires_in)

    changeset
    |> Changeset.put_change(:token, @transfer_token_prefix <> "-" <> Ecto.UUID.generate)
    |> Changeset.put_change(:token_expires_at, expires_at)
  end

  # Store transfer changes into DB
  defp create_transfer(%Changeset{valid?: false} = changeset), do: {:error, changeset}
  defp create_transfer(%Changeset{} = changeset) do
    changeset
    |> TransferSchema.insert
  end

  @doc """
  GET /transfers/:id
  """
  def show(conn, %{"id" => id}) do
    TransferSchema
    |> Repo.get_by(id: id)
    |> validate_query_result()
    |> validate_token(conn)
    |> receive_transfer_status()
    |> update_transfer()
    |> render_response(conn)
  end

  defp receive_transfer_status({:error, reason}), do: {:error, reason}
  defp receive_transfer_status({:ok, %TransferSchema{external_id: external_id} = transfer}) do
    {_, update} = Processing.Adapters.Pay2You.Status.get(external_id)

    transfer = transfer
    |> Changeset.change(update)

    {:ok, transfer}
  end

  @doc """
  POST /transfers/:id/auth
  """
  def authentificate(conn, %{"id" => id} = params) do
    TransferSchema
    |> Repo.get_by(id: id)
    |> validate_query_result()
    |> validate_token(conn)
    |> validate_otp_code(params)
    |> update_transfer()
    |> render_response(conn)
  end

  defp validate_query_result(nil), do: {:error, :not_found}
  defp validate_query_result(%TransferSchema{} = transfer), do: {:ok, transfer}

  defp validate_otp_code({:error, reason}, _params), do: {:error, reason}
  defp validate_otp_code({:ok, %TransferSchema{auth: %AuthorizationLookupCode{} = transfer_auth} = transfer}, params) do
    transfer = case Processing.Adapters.Pay2You.LookupAuth.auth(transfer_auth, params["code"]) do
      {:ok, update} ->
        transfer
        |> Changeset.change(update)
      {:error, :invalid_otp_code} ->
        transfer
        |> Changeset.change()
        |> Changeset.add_error(:code, "is invalid", validation: :otp_code)
      {:error, %{status: _} = error_update} ->
        transfer
        |> Changeset.change(error_update)
    end

    {:ok, transfer}
  end
  defp validate_otp_code({:ok, _transfer}, _params), do: {:error, :not_found}

  defp validate_token({:error, reason}, _conn), do: {:error, reason}
  defp validate_token({:ok, %{token: transfer_token} = transfer}, %Plug.Conn{assigns: %{token: user_token}})
    when transfer_token == user_token,
    do: {:ok, transfer}
  defp validate_token({:ok, _transfer}, _conn), do: {:error, :access_denied}

  defp update_transfer({:error, reason}), do: {:error, reason}
  defp update_transfer({:ok, %Changeset{valid?: false} = changeset}), do: {:error, changeset}
  defp update_transfer({:ok, changeset}) do
    changeset
    |> TransferSchema.update
  end

  # Responses
  defp render_response(state, conn, status \\ :ok)

  defp render_response({:ok, %TransferSchema{} = transfer}, conn, status) do
    conn
    |> put_status(status)
    |> render(TransferView, "transfer.json", transfer: transfer)
  end

  defp render_response({:error, %Changeset{valid?: false} = changeset}, conn, _status) do
    conn
    |> put_status(422)
    |> render(EView.Views.ValidationError, "422.json", changeset)
  end

  defp render_response({:error, :not_found}, conn, _status) do
    conn
    |> put_status(404)
    |> render(EView.Views.Error, "404.json", %{})
  end

  defp render_response({:error, :access_denied}, conn, _status) do
    conn
    |> put_status(401)
    |> render(EView.Views.Error, "401.json", %{})
  end
end
