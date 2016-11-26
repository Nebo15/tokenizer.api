defmodule API.Controllers.Transfer do
  @moduledoc """
  This controller implements REST API to send different kins of transfers and fetch information about them.
  """
  use API.Web, :controller
  alias API.Repo.Schemas.Transfer, as: TransferSchema
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
    |> get_transfer_autorization()
    |> put_transfer_token()
    |> create_transfer()
    |> render_response(conn, :created)
  end

  # Transfer Gateway delegates
  defp get_transfer_autorization(%Changeset{valid?: false} = changeset), do: changeset
  defp get_transfer_autorization(%Changeset{valid?: true} = changeset) do
    external_id = 10000
    |> :rand.uniform()
    |> to_string

    changeset
    |> Changeset.put_change(:auth, %API.Repo.Schemas.Authorization3DS{})
    |> Changeset.put_change(:external_id, external_id)
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
    # |> receive_transfer_status() TODO: get transfer status and persist it
    # |> update_transfer()
    |> render_response(conn)
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
    # |> receive_transfer_status() TODO: get transfer status and persist it
    |> update_transfer()
    |> render_response(conn)
  end

  defp validate_query_result(nil), do: {:error, :not_found}
  defp validate_query_result(%TransferSchema{} = transfer), do: {:ok, transfer}

  defp validate_otp_code({:error, reason}, _params), do: {:error, reason}
  defp validate_otp_code({:ok, transfer}, _params) do
    # TODO validate token via payment services
    # %{}
    # |> Changeset.change(params)
    # |> Changeset.cast([:"otp-code", :id])
    # |> Changeset.validate_required([:"otp-code", :id])
    # |> IO.inspect

    transfer = transfer
    |> Changeset.change()
    |> Changeset.put_change(:status, :completed)

    {:ok, transfer}
  end

  defp update_transfer({:error, reason}), do: {:error, reason}
  defp update_transfer({:ok, changeset}) do
    changeset
    |> TransferSchema.update
  end

  defp validate_token({:error, reason}, _conn), do: {:error, reason}
  defp validate_token({:ok, %{token: transfer_token} = transfer}, %Plug.Conn{assigns: %{token: user_token}})
    when transfer_token == user_token,
    do: {:ok, transfer}
  defp validate_token({:ok, _transfer}, _conn), do: {:error, :access_denied}

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
