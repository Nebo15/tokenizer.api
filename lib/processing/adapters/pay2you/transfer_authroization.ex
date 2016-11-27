# defmodule Processing.Adapters.Pay2You.TransferAuthorization do
#   alias Processing.Adapters.Pay2You.Request
#   alias Processing.Adapters.Pay2You.Error

#         @statuses [
#         auth_waiting: "auth_waiting",
#         completed: "completed",
#         processing: "processing",
#         declined: "declined"
#       ]
#       @auth_types [
#         lookup: "LOOKUP-CODE",
#         ds3: "3D-SECURE"
#       ]


#   @transfer_completion_uri "/ConfirmLookUp/finishlookup"

#   def send(md, code) when is_integer(md) and is_integer(code) do
#     [
#       md: md,
#       paRes: code,
#       cvv: "000"
#     ]
#     |> Request.send_to(@transfer_completion_uri)
#     |> normalize_response
#   end

#   defp normalize_response({:ok, %{"state" => %{"code" => 0}} = transaction}) do
#     {:ok, %{
#       id: transaction["idClient"],
#       status: @statuses[:processing]
#     }}
#   end

#   # Lookup code is not sent yet
#   defp normalize_response({:ok, %{"state" => %{"code" => status_code}}}) when status_code == 49
# or status_code == 59 do
#     {:error, {:validation, :code, "is invalid"}}
#   end

#   # 3DS code is not sent yet
#   defp normalize_response({:ok, %{"state" => %{"code" => status_code}}}) when status_code == 55
# or status_code == 56 do
#     {:error, {:validation, :auth_method, "not allowed for 3DS cards"}}
#   end

#   # Everything else is an error
#   defp normalize_response({:ok, %{"state" => %{"code" => _}} = transaction}) do
#     {:ok, %{
#       id: transaction["idClient"],
#       status: @statuses[:declined],
#       decline: %{
#         reason: ErrorMapper.get_decline_reason(transaction["state"]["code"])
#       }
#     }}
#   end

#   defp normalize_response({:error, reason}) do
#     {:error, reason}
#   end
# end
