# defmodule Processing.Adapters.Pay2You do
#   alias API.Repo.Schemas.Card
#   alias Processing.Adapters.Pay2You.{Transfer, TransferAuthorization, TransferStatus}

#   def transfer(%Card{} = sender, %Card{} = recipient, amount, fee) do
#     Transfer.send(sender, recipient, amount, fee)
#   end

#   def complete_transfer(md, code) when is_integer(md) and is_integer(code) do
#     TransferAuthorization.send(md, code)
#   end

#   def get_transfer_status(id) when is_integer(id) do
#     TransferStatus.get(id)
#   end
# end
