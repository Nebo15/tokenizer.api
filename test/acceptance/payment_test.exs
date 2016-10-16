defmodule Tokenizer.Controllers.PaymentTest do
  use EView.AcceptanceCase,
    async: true,
    otp_app: :tokenizer_api,
    endpoint: Tokenizer.HTTP.Endpoint,
    repo: Tokenizer.DB.Repo

  # alias Tokenizer.DB.Models.Payment

  @payment_raw %{
    amount: 1000,
    fee: "10",
    description: "some content",
    metadata: %{
      feel_free: "to set any metadata"
    },
    recipient: %{
      type: "card",
      phone: "+380631112233",
      email: "ivan@example.com",
      card: %{
        number: "5473959513413611"
      }
    },
    sender: %{
      type: "card",
      phone: "+380631112233",
      email: "ivan@example.com",
      card: %{
        number: "5473959513413611",
        cvv: "160",
        expiration_month: "01",
        expiration_year: "2020"
      }
    }
  }

  @payment_raw_invalid %{
    amount: 1000,
    fee: "10",
    description: "some content",
    metadata: %{
      feel_free: "to set any metadata"
    },
    recipient: %{
      type: "card",
      phone: "+380631112233",
      email: "ivan@example.com",
      card: %{
        number: "1473959513413611"
      }
    },
    sender: %{
      type: "card",
      phone: "+380631112233",
      email: "ivan@example.com",
      card: %{
        number: "5473959513413611",
        cvv: "160",
        expiration_month: "01",
        expiration_year: "20"
      }
    }
  }

  test "create payment with raw card data" do
    assert %{
      "meta" => %{
        "code" => 201
      },
      "data" => %{
        "type" => "card",
        "token" => _,
        "token_expires_at" => _
      }
    } = "payments"
    |> post!(@payment_raw)
    |> get_body
  end

  # test "create invalid payment with raw card data" do
  #   assert %{
  #     "meta" => %{
  #       "code" => 422
  #     },
  #     "error" => _
  #   } = "payments"
  #   |> post!(@payment_raw_invalid)
  #   |> get_body
  # end
end


# # defmodule Mbill.PaymentControllerTest do
# #   use Mbill.ConnCase,
# async: true

# #   alias Mbill.Payment

#   @valid_attrs %{
#     amount: 1000,
#     fee: "10",
#     description: "some content",
#     recipient: %{
#       type: "card",
#       phone: "+380631112233",
#       email: "ivan@example.com",
#       card: %{number: "5473959513413611"}
#     },
#     sender: %{
#       type: "card",
#       phone: "+380631112233",
#       email: "ivan@example.com",
#       card: %{
#         number: "5473959513413611", cvv: "160", expiration_month: "01", expiration_year: "20"
#       }
#     }
#   }

#   @invalid_attrs %{amount: "invalid"}

#   @response_card %{
#     "type" => %{"type" => "string"},
#     "phone" => %{"type" => "string"},
#     "email" => %{"type" => "string"},
#     "card" => %{
#       "type" => "object",
#       "properties" => %{
#         "number" => %{"type" => "string"},
#       }
#     }
#   }

#   @response_meta %{
#     "type" => "object",
#     "properties" => %{
#       "code" => %{"type" => "integer"},
#     }
#   }

#   @response_payment %{
#     "type" => "object",
#     "properties" => %{
#       "meta" => @response_meta,
#       "data" => %{
#         "type" => "object",
#         "properties" => %{
#           "id" => %{"type" => "integer"},
#           "pay2you_id"=> %{"type" => "integer"},
#           "amount" => %{"type" => "number"},
#           "fee" => %{"type" => "number"},
#           "description" => %{"type" => "string"},
#           "token" => %{"type" => "string"},
#           "token_expires" => %{"type" => "string"},
#           "status" => %{"type" => "string"},
#           "created_at" => %{"type" => "string"},
#           "updated_at" => %{"type" => "string"},
#           "sender"=> %{
#             "type" => "object",
#             "properties" => @response_card
#           },
#           "recipient"=> %{
#             "type" => "object",
#             "properties" => @response_card
#           },
#           "auth"=> %{
#             "type" => "object",
#             "properties" => %{
#               "type" => %{"type" => "string"},
#               "md" => %{"type" => "integer"},
#             }
#           },
#         },
#       },
#     }
#   }

#   @response_err_validation %{
#     "type" => "object",
#     "properties" => %{
#       "meta" => @response_meta,
#       "errors" => %{
#         "type" => "object",
#         "properties" => %{
#           "code" => %{"type" => "integer"},
#           "type" => %{"type" => "string"},
#           "invalid" => %{
#             "type" => "array",
#           }
#         }
#       }
#     }
#   }

#   setup %{conn: conn} do
#     {:ok, conn: put_req_header(conn, "accept", "application/json")}
#   end

#   test "create and get payment when data is valid", %{conn: conn} do
#     conn = post conn, payment_path(conn, :create), @valid_attrs

#     json_resp = json_response(conn, 201)
#     assert_payment json_resp
#     assert Repo.get_by(Payment, %{amount: 1000})

#     created_at = json_resp["data"]["created_at"]

#     conn = get conn, "/api/v1/payments/" <> Integer.to_string(json_resp["data"]["pay2you_id"])

#     json_response(conn, 201)
#     |> assert_payment
#     |> assert_token_expiration(created_at)
#   end

#   test "does not create resource and renders errors when data is invalid", %{conn: conn} do
#     conn = post conn, payment_path(conn, :create), %{amount: "invalid"}

#     res = json_response(conn, 422)
#     assert422 res
#     assert json_response(conn, 422)["errors"]["invalid"] == [%{
#       "amount" => ["is invalid"],
#       "fee" => ["can't be blank"],
#       "recipient" => ["can't be blank"],
#       "sender" => ["can't be blank"]
#     }]
#   end

#   test "lists all entries does not exist", %{conn: conn} do
#     conn = get conn, "/api/v1/payments/"
#     assert response(conn, 404)
#   end

#   test "UPDATE does not exist", %{conn: conn} do
#     payment = Repo.insert! %Payment{}
#     conn = put conn, payment_path(conn, :show, payment), payment: @valid_attrs
#     assert conn.status == 404
#   end

#   test "renders page not found when id is nonexistent", %{conn: conn} do
#     assert_error_sent 404, fn ->
#       get conn, payment_path(conn, :show, -1)
#     end
#   end

#   test "DELETE does not exist", %{conn: conn} do
#     payment = Repo.insert! %Payment{}
#     conn = delete conn, payment_path(conn, :show, payment)
#     assert response(conn, 404)
#   end

#   defp assert_payment(res) do
#     assert ExJsonSchema.Validator.validate(@response_payment, res) == :ok
#     res
#   end

#   defp assert_token_expiration(res, created_at) do
#     {:ok, created_at} = Ecto.DateTime.cast(created_at)
#     {:ok, expires} = Ecto.DateTime.cast(res["data"]["token_expires"])
#     assert :gt == Ecto.DateTime.compare(expires, created_at)

#     res
#   end

#   defp assert422(res) do
#     assert ExJsonSchema.Validator.validate(@response_err_validation, res) == :ok
#     res
#   end
# end
