defmodule Tokenizer.Controllers.Transfer do
  @moduledoc """
  This controller implements REST API to send different kins of transfers and fetch information about them.
  """
  use Tokenizer.Web, :controller

  alias Tokenizer.DB.Schemas.Transfer, as: TransferSchema
  alias Tokenizer.Views.Transfer, as: TransferView
  alias Tokenizer.CardStorage.Supervisor, as: CardStorage
  alias Tokenizer.DB.Repo
  alias Ecto.Changeset

  @transfer_token_prefix "transfer-token"

  # Actions

  @doc """
  POST /transfers
  """
  def create(conn, params) when is_map(params) do
    %TransferSchema{}
    |> TransferSchema.changeset(params)
    |> map_changeset()
    |> resolve_sender_credentials()
    |> resolve_recipient_credentials()
    |> get_transfer_autorization()
    |> put_transfer_token()
    |> create_transfer()
    |> send_response(:created, conn)
  end

  # Transfer Gateway delegates
  # TODO: resolve recipients token
  defp resolve_sender_credentials({:error, :invalid, changeset}), do: {:error, :invalid, changeset}
  defp resolve_sender_credentials({:ok, %Changeset{valid?: true,
                                                   changes: %{
                                                     sender: %{
                                                       changes: %{
                                                         credential: %{
                                                           changes: %{token: token},
                                                           data: %{type: "card-token"}
                                                         } = credential
                                                       }
                                                     } = sender
                                                   }
                                  } = changeset}) do
    case CardStorage.get_card(token) do
      {:ok, card_data} ->
        sender = sender
        |> Changeset.put_embed(:credential, card_data)

        changeset = changeset
        |> Changeset.put_embed(:sender, sender)

        {:ok, changeset}
      {:error, _} ->
        credential = credential
        |> Changeset.add_error(:token, "is invalid", validation: :token)

        sender = sender
        |> Changeset.put_embed(:credential, credential)

        changeset = changeset
        |> Changeset.put_embed(:sender, sender)

        {:error, :invalid, changeset}
    end
  end
  defp resolve_sender_credentials({:ok, changeset}), do: {:ok, changeset}

  defp resolve_recipient_credentials({:error, :invalid, changeset}), do: {:error, :invalid, changeset}
  defp resolve_recipient_credentials({:ok, %Changeset{valid?: true,
                                                   changes: %{
                                                     recipient: %{
                                                       changes: %{
                                                         credential: %{
                                                           changes: %{token: token},
                                                           data: %{type: "card-token"}
                                                         } = credential
                                                       }
                                                     } = recipient
                                                   }
                                  } = changeset}) do
    case CardStorage.get_card(token) do
      {:ok, card_data} ->
        recipient = recipient
        |> Changeset.put_embed(:credential, card_data)

        changeset = changeset
        |> Changeset.put_embed(:recipient, recipient)

        {:ok, changeset}
      {:error, _} ->
        credential = credential
        |> Changeset.add_error(:token, "is invalid", validation: :token)

        recipient = recipient
        |> Changeset.put_embed(:credential, credential)

        changeset = changeset
        |> Changeset.put_embed(:recipient, recipient)

        {:error, :invalid, changeset}
    end
  end
  defp resolve_recipient_credentials({:ok, changeset}), do: {:ok, changeset}

  defp get_transfer_autorization({:error, reason, details}), do: {:error, reason, details}
  defp get_transfer_autorization({:ok, %Changeset{} = changeset}) do
    external_id = 10000
    |> :rand.uniform()
    |> to_string

    changeset = changeset
    |> Changeset.put_change(:auth, %Tokenizer.DB.Schemas.Authorization3DS{})
    |> Changeset.put_change(:external_id, external_id)

    {:ok, changeset}
  end

  defp put_transfer_token({:error, reason, details}), do: {:error, reason, details}
  defp put_transfer_token({:ok, %Changeset{} = changeset}) do
    expires_in = Confex.get(:tokenizer_api, :transfer_token_expires_in)

    expires_at = Timex.now
    |> Timex.shift(microseconds: expires_in)

    {:ok, changeset
          |> Changeset.put_change(:token, @transfer_token_prefix <> "-" <> Ecto.UUID.generate)
          |> Changeset.put_change(:token_expires_at, expires_at)}
  end

  # Store transfer changes into DB
  defp create_transfer({:error, reason, details}), do: {:error, reason, details}
  defp create_transfer({:ok, %Changeset{valid?: false} = changeset}), do: {:error, :invalid, changeset}
  defp create_transfer({:ok, %Changeset{valid?: true} = changeset}) do
    changeset
    |> TransferSchema.insert
  end

  @doc """
  GET /transfers/:id
  """
  def show(conn, %{"id" => id}) do
    TransferSchema
    |> Repo.get_by(id: id)
    |> check_query_result
    |> validate_token(conn)
    # |> receive_transfer_status() TODO: get transfer status and persist it
    |> send_response(:ok, conn)
  end

  @doc """
  POST /transfers/:id/auth
  """
  def authentificate(conn, %{"id" => id} = params) do
    TransferSchema
    |> Repo.get_by(id: id)
    |> check_query_result
    |> validate_token(conn)
    |> validate_otp_code(params)
    |> update_transfer()
    # |> receive_transfer_status() TODO: get transfer status and persist it
    |> send_response(:ok, conn)
  end

  defp validate_otp_code({:error, reason}, _params), do: {:error, reason}
  defp validate_otp_code({:ok, transfer}, params) do
    # TODO validate token via payment services
    # %{}
    # |> Changeset.change(params)
    # |> Changeset.cast([:"otp-code", :id])
    # |> Changeset.validate_required([:"otp-code", :id])
    # |> IO.inspect

    {:ok, transfer
          |> Changeset.change()
          |> Changeset.put_change(:status, :completed)}
  end

  defp update_transfer({:error, reason}), do: {:error, reason}
  defp update_transfer({:ok, changeset}) do
    changeset
    |> TransferSchema.update
  end

  defp check_query_result(nil), do: {:error, :not_found}
  defp check_query_result(%TransferSchema{} = transfer), do: {:ok, transfer}

  defp validate_token({:error, reason}, _conn), do: {:error, reason}
  defp validate_token({:ok, %{token: transfer_token} = transfer}, %Plug.Conn{assigns: %{token: user_token}})
       when transfer_token == user_token, do: {:ok, transfer}
  defp validate_token({:ok, _transfer}, _conn), do: {:error, :access_denied}

  defp map_changeset(%Changeset{valid?: false} = changeset), do: {:error, :invalid, changeset}
  defp map_changeset(%Changeset{valid?: true} = changeset), do: {:ok, changeset}

  # Responses
  defp send_response({:ok, %TransferSchema{} = transfer}, status, conn) do
    conn
    |> put_status(status)
    |> render(TransferView, "transfer.json", transfer: transfer)
  end

  defp send_response({:error, :invalid, %Changeset{} = changeset}, _status, conn) do
    conn
    |> put_status(422)
    |> render(EView.Views.ValidationError, "422.json", changeset)
  end

  defp send_response({:error, :not_found}, _status, conn) do
    conn
    |> put_status(404)
    |> render(EView.Views.Error, "404.json", %{})
  end

  defp send_response({:error, :access_denied}, _status, conn) do
    conn
    |> put_status(401)
    |> render(EView.Views.Error, "401.json", %{})
  end
end
