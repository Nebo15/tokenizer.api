defmodule Tokenizer.Controllers.Payment do
  use Tokenizer.Web, :controller

  alias Tokenizer.DB.Models.Payment, as: PaymentSchema
  alias Tokenizer.Views.Payment, as: PaymentView

  # Actions
  def create(conn, params) when is_map(params) do
    %PaymentSchema{}
    |> PaymentSchema.creation_changeset(params)
    |> get_payment_autorization
    |> store_payment
    |> send_response(conn)
  end

  # def show(conn, %{"id" => id}) do
  #   payment = Repo.get_by!(Payment, pay2you_id: id)
  #   String.to_integer(id)
  #   |> Pay2You.get_transfer_status
  #   |> Mbill.Service.Payments.update_status(payment)
  #   |> send_response(conn)
  # end

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

  # Payment Gateway delegates
  defp get_payment_autorization(%Ecto.Changeset{valid?: false} = changeset), do: {:error, :invalid, changeset}
  defp get_payment_autorization(%Ecto.Changeset{valid?: true} = changeset) do
    changeset = changeset
    |> Ecto.Changeset.put_change(:auth, %Tokenizer.DB.Models.Authorization3DS{})
    |> Ecto.Changeset.put_change(:external_id, "007")
    |> put_token

    {:ok, changeset}
  end

  defp put_token(%Ecto.Changeset{} = changeset) do
    expires_in = Confex.get(:tokenizer_api, :payment_token_expires_in)

    expires_at = Timex.now
    |> Timex.shift(microseconds: expires_in)

    changeset
    |> Ecto.Changeset.put_change(:token, "payment-" <> Ecto.UUID.generate)
    |> Ecto.Changeset.put_change(:token_expires_at, expires_at)
  end

  # Store payment changes into DB
  defp store_payment({:error, reason}), do: {:error, reason}
  defp store_payment({:error, reason, details}), do: {:error, reason, details}
  defp store_payment({:ok, %Ecto.Changeset{} = changeset}) do
    changeset
    |> PaymentSchema.changeset
    |> IO.inspect
    |> Tokenizer.DB.Repo.insert
  end

  # Responses
  defp send_response({:ok, %PaymentSchema{} = payment}, conn) do
    conn
    |> put_status(:created)
    |> render(PaymentView, "payment.json", payment: payment)
  end

  defp send_response({:error, :invalid, %Ecto.Changeset{} = changeset}, conn) do

    IO.inspect changeset

    conn
    |> put_status(422)
    |> render(EView.ValidationErrorView, "422.json", changeset)
  end

  # defp send_response({:error, %{id: _, status: _, decline: _} = reason}, conn) do
  #   conn
  #   |> put_status(400)
  #   |> render(Mbill.ErrorView, "pay2you_400.json", errors: reason)
  # end

  # defp send_response({:error, %{pay2you: true, reason: reason}}, conn) do
  #   conn
  #   |> put_status(400)
  #   |> render(Mbill.ErrorView, "pay2you_400.json", errors: reason)
  # end

  # defp send_response({:error, {:validation, param, msg}}, conn) do
  #   conn
  #   |> put_status(422)
  #   |> render(Mbill.ErrorView, "422.json", %{param: param, msg: msg, type: "invalid_completion_code"})
  # end

  # defp send_response({:error, changeset: changeset}, conn) do
  #   conn
  #   |> put_status(422)
  #   |> render(Mbill.ErrorView, "422.json", %{changeset: changeset})
  # end

  # defp send_response({:error, reason}, conn) do
  #   conn
  #   |> put_status(400)
  #   |> render(Mbill.ErrorView, "400.json", errors: reason)
  # end
end
