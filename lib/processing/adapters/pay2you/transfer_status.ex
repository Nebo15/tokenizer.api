# defmodule Processing.Adapters.Pay2You.TransferStatus do
#   alias Pay2You.Request
#   alias Pay2You.ErrorMapper

#   use Pay2You.DictsMacro

#   @transfer_status_uri "/Info/GetPayStatus"

#   def get(id) when is_integer(id) do
#     [
#       mPayNumber: id
#     ]
#     |> Request.send_to(@transfer_status_uri)
#     |> normalize_response
#   end

#   # 3DS code is not sent yet
#   defp normalize_response({:ok, %{"mErrCode" => status_code} = transaction})
# when status_code == 55 or status_code == 56 do
#     {:ok, %{
#       id: transaction["mPayNumber"],
#       status: @statuses[:auth_waiting],
#       auth: %{
#         type: @auth_types[:ds3]
#       }
#     }}
#   end

#   # Lookup code is not sent yet
#   defp normalize_response({:ok, %{"mErrCode" => status_code} = transaction})
# when status_code == 49 or status_code == 59 do
#     {:ok, %{
#       id: transaction["mPayNumber"],
#       status: @statuses[:auth_waiting],
#       auth: %{
#         type: @auth_types[:lookup]
#       }
#     }}
#   end

#   # Successful payment
#   defp normalize_response({:ok, %{"mErrCode" => 0} = transaction}) do
#     {:ok, %{
#       id: transaction["mPayNumber"],
#       status: @statuses[:completed]
#     }}
#   end

#   # Everything else is an error
#   defp normalize_response({:ok, %{"mErrCode" => _} = transaction}) do
#     {:ok, %{
#       id: transaction["mPayNumber"],
#       status: @statuses[:declined],
#       decline: %{
#         reason: ErrorMapper.get_decline_reason(transaction["mErrCode"]),
#         error_code: transaction["mErrCode"]
#       }
#     }}
#   end

#   defp normalize_response({:ok, %{"code" => code, "error" => err}}) do
#     {:error, %{code: code, error: err}}
#   end

#   defp normalize_response({:error, reason}) do
#     {:error, reason}
#   end
# end
