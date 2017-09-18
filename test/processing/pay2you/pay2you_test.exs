defmodule Processing.Adapters.Pay2You.Pay2YouTest do
  use ExUnit.Case, async: true

  alias Repo.Schemas.Card
  alias Pay2You.Structs.SenderCard
  alias Pay2You.Structs.RecipientPeer
  alias Pay2You.Structs.RecipientCard
  alias Processing.Adapters.Pay2You.Transfer

  test "send card2card" do
    card = %Card{cvv: "190", expiration_month: "12", expiration_year: "18",
      number: "4242424242424242", type: "card"}
    recipient = %Repo.Schemas.CardNumber{number: "5363542306736662"}
    amount = Decimal.new(1)
    fee = Decimal.new(1)
    phone = "+380631817386"

    Transfer.send(card, recipient, amount, fee, phone)
  end
#   setup do
#     [
#       peer_2ds: %SenderPeer{
#         card: %SenderCard{
#           number: "5591587543706253",
#           expiration_month: "01",
#           expiration_year: "20",
#           cvv: "160"
#         },
#         email: "user@example.com",
#         phone: "+380631111111"
#       },

#       peer_declined: %SenderPeer{
#         card: %SenderCard{
#           number: "5232747764071184",
#           expiration_month: "01",
#           expiration_year: "20",
#           cvv: "1601"
#         },
#         email: "user@example.com",
#         phone: "+380631111111"
#       },

#       peer_3ds: %SenderPeer{
#         card: %SenderCard{
#           number: "5473959513413611",
#           expiration_month: "01",
#           expiration_year: "20",
#           cvv: "160"
#         },
#         email: "user@example.com",
#         phone: "+380631111111"
#       },

#       recipient_card: %RecipientPeer{
#         card: %RecipientCard{
#           number: "5473959513413611"
#         }
#       }
#     ]
#   end

#   test "maps error codes" do
#     assert "Internal_Error__P2Y" == Pay2You.ErrorMapper.get_decline_reason(1)
#     assert "Card_Expired" == Pay2You.ErrorMapper.get_decline_reason(6)
#   end

#   test "create 2ds payment", context do
#     assert {:ok, %{
#       auth: %{
#         md: _,
#         type: "LOOKUP-CODE"
#       },
#       status: "auth_waiting",
#       id: _
#     }} = Pay2You.transfer(context[:peer_2ds], context[:recipient_card], 1, 5.01)
#   end

#   test "create 2ds payment with invalid fee", context do
#     assert {:error,
#       [[{:fee, :fee, "is invalid"}]]
#     } = Pay2You.transfer(context[:peer_2ds], context[:recipient_card], 1, 5.04)
#   end

#   test "create 2ds payment with back-end error", context do
#     assert {:ok, %{
#       decline: %{reason: "Card_Expired"},
#       id: _,
#       status: "declined"
#     }} = Pay2You.transfer(context[:peer_declined], context[:recipient_card], 1, 5.01)
#   end

#   test "complete 2ds payment", context do
#     {:ok, payment} = Pay2You.transfer(context[:peer_2ds], context[:recipient_card], 1, 5.01)
#     assert {:ok, %{
#       id: _,
#       status: "processing"
#     }} = Pay2You.complete_transfer(payment.auth.md, 123456)
#   end

#   test "complete 2ds payment with invalid lookup code", context do
#     {:ok, payment} = Pay2You.transfer(context[:peer_2ds], context[:recipient_card], 1, 5.01)
#     assert {:error, {:validation, :code, "is invalid"}} = Pay2You.complete_transfer(payment.auth.md, 123455)
#   end

#   test "create 3ds payment", context do
#     assert {:ok, %{
#       auth: %{
#         acs_url: _,
#         md: _,
#         pa_req: _,
#         terminal_url: _,
#         type: "3D-SECURE"
#       },
#       status: "auth_waiting",
#       id: _
#     }} = Pay2You.transfer(context[:peer_3ds], context[:recipient_card], 1, 5.01)
#   end

#    test "complete 3ds payment with lookup code", context do
#      {:ok, payment} = Pay2You.transfer(context[:peer_3ds], context[:recipient_card], 1, 5.01)
#      assert {:error,
#        {:validation, :auth_method, "not allowed for 3DS cards"}
#      } = Pay2You.complete_transfer(payment.auth.md, 123456)
#    end

#   test "get payment status for 2ds card", context do
#     assert {:ok, %{
#       auth: %{
#         md: _,
#         type: "LOOKUP-CODE"
#       },
#       id: _,
#       status: "auth_waiting"
#     } = payment} = Pay2You.transfer(context[:peer_2ds], context[:recipient_card], 1, 5.01)

#      assert {:ok, %{
#        auth: %{
#          type: "LOOKUP-CODE"
#        },
#        id: _,
#        status: "auth_waiting"
#      }} = Pay2You.get_transfer_status(payment.id)

#     assert {:ok, %{
#       id: _,
#       status: "processing"
#     }} = Pay2You.complete_transfer(payment.auth.md, 123456)

#     assert {:ok, %{
#       id: _,
#       status: "completed"
#     }} = Pay2You.get_transfer_status(payment.id)
#   end

#   test "get payment status for 3ds card", context do
#     assert {:ok, %{
#       auth: %{
#         acs_url: _,
#         md: _,
#         pa_req: _,
#         terminal_url: _,
#         type: "3D-SECURE"
#       },
#       status: "auth_waiting",
#       id: _
#     } = payment} = Pay2You.transfer(context[:peer_3ds], context[:recipient_card], 1, 5.01)

#      assert {:ok, %{
#        auth: %{
#          type: "3D-SECURE"
#        },
#        id: _,
#        status: "auth_waiting"
#      }} = Pay2You.get_transfer_status(payment.id)

#     # Confirm 3DS transfer
#     HTTPoison.post!(payment.auth.acs_url, {:form, [
#       {"PaReq", payment.auth.pa_req},
#       {"MD", payment.auth.md},
#       {"TermUrl", payment.auth.terminal_url}
#     ]})

#     HTTPoison.post!(payment.auth.terminal_url, {:form, [
#       {"ds3", "123456"},
#       {"md", payment.auth.md}
#     ]})

#      assert {:ok, %{
#        id: _,
#        status: "completed"
#      }} = Pay2You.get_transfer_status(payment.id)
#   end

#   test "get failed status", context do
#     assert {:ok, %{
#       auth: %{
#         acs_url: _,
#         md: _,
#         pa_req: _,
#         terminal_url: _,
#         type: "3D-SECURE"
#       },
#       status: "auth_waiting",
#       id: _
#     } = payment} = Pay2You.transfer(context[:peer_3ds], context[:recipient_card], 1, 5.01)

#      assert {:ok, %{
#        auth: %{
#          type: "3D-SECURE"
#        },
#        id: _,
#        status: "auth_waiting"
#      }} = Pay2You.get_transfer_status(payment.id)

#      HTTPoison.post!(payment.auth.acs_url, {:form, [
#        {"PaReq", payment.auth.pa_req},
#        {"MD", payment.auth.md},
#        {"TermUrl", payment.auth.terminal_url}
#      ]})

#      HTTPoison.post!(payment.auth.terminal_url, {:form, [
#        {"ds3", "123155"},
#        {"md", payment.auth.md}
#      ]})
#     assert {:ok, %{
#       id: _,
#       status: "declined",
#       decline: %{
#         reason: "3DS_Failed"
#       }
#     }} = Pay2You.get_transfer_status(payment.id)
#   end
end
