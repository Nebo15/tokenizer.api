# defmodule Tokenizer.Controllers.Payment do
#   use Tokenizer.Web, :controller

#   alias Pay2You
#   alias Mbill.Payment
#   alias Mbill.PaymentRequest

#   # Actions
#   def create(conn, payment_params) when is_map(payment_params) do
#     PaymentRequest.changeset(%PaymentRequest{}, payment_params)
#     |> Mbill.Service.Payments.create(payment_params)
#     |> send_response(conn)
#   end

#   def show(conn, %{"id" => id}) do
#     payment = Repo.get_by!(Payment, pay2you_id: id)
#     String.to_integer(id)
#     |> Pay2You.get_transfer_status
#     |> Mbill.Service.Payments.update_status(payment)
#     |> send_response(conn)
#   end

#   def complete(conn, %{"id" => id, "code" => code}) do

#     payment = Repo.get_by!(Payment, pay2you_id: id)
#     Pay2You.complete_transfer(payment.auth["md"], code)
#     |> Mbill.Service.Payments.update_status(payment)
#     |> send_response(conn)
#   end

#   def complete(conn, _params) do
#     # ToDo: render 422 error
#     render conn, Mbill.ErrorView, "404.json"
#   end

#   # Responses
#   defp send_response({:ok, payment}, conn) do
#     conn
#     |> put_status(:created)
#     |> put_resp_header("location", payment_path(conn, :show, payment))
#     |> render("show.json", payment: payment)
#   end

#   defp send_response({:error, %{id: _, status: _, decline: _} = reason}, conn) do
#     conn
#     |> put_status(400)
#     |> render(Mbill.ErrorView, "pay2you_400.json", errors: reason)
#   end

#   defp send_response({:error, %{pay2you: true, reason: reason}}, conn) do
#     conn
#     |> put_status(400)
#     |> render(Mbill.ErrorView, "pay2you_400.json", errors: reason)
#   end

#   defp send_response({:error, {:validation, param, msg}}, conn) do
#     conn
#     |> put_status(422)
#     |> render(Mbill.ErrorView, "422.json", %{param: param, msg: msg, type: "invalid_completion_code"})
#   end

#   defp send_response({:error, changeset: changeset}, conn) do
#     conn
#     |> put_status(422)
#     |> render(Mbill.ErrorView, "422.json", %{changeset: changeset})
#   end

#   defp send_response({:error, reason}, conn) do
#     conn
#     |> put_status(400)
#     |> render(Mbill.ErrorView, "400.json", errors: reason)
#   end
# end
