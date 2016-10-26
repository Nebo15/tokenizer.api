defmodule Tokenizer.Controllers.Payment do
  use Tokenizer.Web, :controller

  alias Tokenizer.DB.Models.Payment, as: PaymentSchema
  alias Tokenizer.Views.Payment, as: PaymentView

  @payment_token_prefix "payment"

  # Actions
  def create(conn, params) when is_map(params) do
    %PaymentSchema{}
    |> PaymentSchema.creation_changeset(params)
    |> get_payment_autorization
    |> put_payment_token
    |> validate_payment
    |> save_payment
    |> send_response(conn)
  end

  # def show(conn, %{"id" => id}) do
  #   Tokenizer.DB.Repo.get_by(Payment, external_id: id)

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

  # Prepare payment changeset
  defp validate_payment({:error, reason, details}), do: {:error, reason, details}
  defp validate_payment({:ok, %Ecto.Changeset{} = changeset}) do
    {:ok, PaymentSchema.changeset(changeset)}
  end

  # Store payment changes into DB
  defp save_payment({:error, reason, details}), do: {:error, reason, details}
  defp save_payment({:ok, %Ecto.Changeset{valid?: false} = changeset}), do: {:error, :invalid, changeset}
  defp save_payment({:ok, %Ecto.Changeset{valid?: true} = changeset}) do
    changeset
    |> Tokenizer.DB.Repo.insert
  end

  # Responses
  defp send_response({:ok, %PaymentSchema{} = payment}, conn) do
    conn
    |> put_status(:created)
    |> render(PaymentView, "payment.json", payment: payment)
  end

  defp send_response({:error, :invalid, %Ecto.Changeset{} = changeset}, conn) do
    conn
    |> put_status(422)
    |> render(EView.ValidationErrorView, "422.json", changeset)
  end
end
