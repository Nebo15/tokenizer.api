defmodule Tokenizer.Controllers.Payment do
  @moduledoc """
  This controller implements REST API to send different kins of payments and fetch information about them.
  """
  use Tokenizer.Web, :controller

  alias Tokenizer.DB.Schemas.Payment, as: PaymentSchema
  alias Tokenizer.Views.Payment, as: PaymentView
  alias Tokenizer.CardStorage.Supervisor, as: CardStorage
  alias Tokenizer.DB.Repo

  @payment_token_prefix "payment"

  # Actions

  @doc """
  POST /payments
  """
  def create(conn, params) when is_map(params) do
    %PaymentSchema{}
    |> PaymentSchema.changeset(params)
    |> resolve_credential_token
    |> get_payment_autorization
    |> put_payment_token
    |> save_payment
    |> send_response(:created, conn)
  end

  # Payment Gateway delegates
  defp resolve_credential_token(%Ecto.Changeset{valid?: false} = changeset), do: {:error, :invalid, changeset}
  defp resolve_credential_token(%Ecto.Changeset{valid?: true, changes: %{sender: %{
                                                                changes: %{credential: %{
                                                                  changes: %{token: token},
                                                                  data: %{type: "card-token"}} = credential}} = sender}} = changeset) do
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

        {:error, :token_invalid, changeset}
    end
  end
  defp resolve_credential_token(%Ecto.Changeset{valid?: true, changes: %{sender: %{
                                                                changes: %{credential: %{
                                                                  data: %{type: _}}}}}} = changeset) do
    {:ok, changeset}
  end

  defp get_payment_autorization({:error, reason, details}), do: {:error, reason, details}
  defp get_payment_autorization({:ok, %Ecto.Changeset{} = changeset}) do
    changeset = changeset
    |> Ecto.Changeset.put_change(:auth, %Tokenizer.DB.Schemas.Authorization3DS{})

    {:ok, changeset}
  end

  defp put_payment_token({:error, reason, details}), do: {:error, reason, details}
  defp put_payment_token({:ok, %Ecto.Changeset{} = changeset}) do
    expires_in = Confex.get(:tokenizer_api, :payment_token_expires_in)

    expires_at = Timex.now
    |> Timex.shift(microseconds: expires_in)

    {:ok, changeset
          |> Ecto.Changeset.put_change(:token, @payment_token_prefix <> "-" <> Ecto.UUID.generate)
          |> Ecto.Changeset.put_change(:token_expires_at, expires_at)}
  end

  # Store payment changes into DB
  defp save_payment({:error, reason, details}), do: {:error, reason, details}
  defp save_payment({:ok, %Ecto.Changeset{valid?: false} = changeset}), do: {:error, :invalid, changeset}
  defp save_payment({:ok, %Ecto.Changeset{valid?: true} = changeset}) do
    changeset
    |> PaymentSchema.insert
  end

  @doc """
  GET /payments/:id?token=token
  """
  def show(conn, %{"id" => id, "token" => token}) do
    PaymentSchema
    |> Repo.get_by(id: id)
    |> check_query_result
    |> validate_token(token)
    #|> update_payment_status TODO: get payment status and persist it
    |> send_response(:ok, conn)
  end

  defp check_query_result(nil), do: {:error, :not_found}
  defp check_query_result(%PaymentSchema{} = payment), do: {:ok, payment}

  defp validate_token({:error, reason}, _), do: {:error, reason}
  defp validate_token({:ok, %{token: payment_token} = payment}, user_token) when payment_token == user_token do
    {:ok, payment}
  end

  defp validate_token({:ok, _}, _) do
    {:error, :access_denied}
  end

  # def complete(conn, %{"id" => id, "code" => code}) do
  #   payment = Repo.get_by!(Payment, pay2you_id: id)
  #   Pay2You.complete_transfer(payment.auth["md"], code)
  #   |> Mbill.Service.Payments.update_status(payment)
  #   |> send_response(conn)
  # end

  # def complete(conn, _params) do
  #   # ToDo: render 422 error
  #   render conn, Mbill.ErrorView, "404.json"
  # end

  # Responses
  defp send_response({:ok, %PaymentSchema{} = payment}, status, conn) do
    conn
    |> put_status(status)
    |> render(PaymentView, "payment.json", payment: payment)
  end

  defp send_response({:error, :token_invalid, %Ecto.Changeset{} = changeset}, _, conn) do
    conn
    |> put_status(422)
    |> render(EView.ValidationErrorView, "422.json", changeset)
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
