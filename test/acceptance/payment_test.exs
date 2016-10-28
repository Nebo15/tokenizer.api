defmodule Tokenizer.Controllers.PaymentTest do
  use EView.AcceptanceCase,
    async: true,
    otp_app: :tokenizer_api,
    endpoint: Tokenizer.HTTP.Endpoint,
    repo: Tokenizer.DB.Repo

  @card_credential %{
    type: "card",
    number: "5473959513413611",
    cvv: "160",
    expiration_month: "01",
    expiration_year: "2020"
  }

  @card_number_credential %{
    type: "card-number",
    number: "5473959513413611"
  }

  @payment_raw_invalid %{
    amount: 1000,
    fee: "10",
    description: "some content",
    metadata: %{
      feel_free: "to set any metadata"
    },
    recipient: %{
      phone: "+380631112233",
      email: "ivan@example.com",
      credential: %{
        type: "card-number",
        number: "1473959513413611"
      }
    },
    sender: %{
      phone: "+380631112233",
      email: "ivan@example.com",
      credential: %{
        type: "card",
        number: "5473959513413611",
        cvv: "160",
        expiration_month: "01",
        expiration_year: "20"
      }
    }
  }

  @payment_raw_invalid_type %{
    amount: 1000,
    fee: "10",
    description: "some content",
    metadata: %{
      feel_free: "to set any metadata"
    },
    recipient: %{
      phone: "+380631112233",
      email: "ivan@example.com",
      credential: %{
        type: "card",
        number: "5473959513413611",
        cvv: "160",
        expiration_month: "01",
        expiration_year: "2020"
      }
    },
    sender: %{
      phone: "+380631112233",
      email: "ivan@example.com",
      credential: %{
        type: "card-number",
        number: "5473959513413611"
      }
    }
  }

  defp construct_payment(sender_credential \\ @card_credential, recipient_credential \\ @card_number_credential) do
    %{
      amount: 1000,
      fee: "10",
      description: "some content",
      metadata: %{
        feel_free: "to set any metadata"
      },
      sender: %{
        phone: "+380631112233",
        email: "ivan@example.com",
        credential: sender_credential
      },
      recipient: %{
        phone: "+380631112233",
        email: "ivan@example.com",
        credential: recipient_credential
      }
    }
  end

  defp assert_payment(resp) do
    resp_body = get_body(resp)

    assert %{
      "meta" => %{
        "code" => _
      },
      "data" => %{
        "id" => _,
        "amount" => _,
        "fee" => _,
        "auth" => %{"acs_url" => nil, "md" => nil, "pa_req" => nil, "terminal_url" => nil, "type" => "3d_secure"},
        "description" => "some content",
        "external_id" => "007",
        "status" => "authorization",
        "token" => _,
        "token_expires_at" => _,
        "type" => "payment",
        "metadata" => %{"feel_free" => "to set any metadata"},
        "recipient" => %{"credential" => _, "email" => "ivan@example.com", "phone" => "+380631112233"},
        "sender" => %{"credential" => _, "email" => "ivan@example.com", "phone" => "+380631112233"},
        "created_at" => _,
        "updated_at" => _
      }
    } = resp_body

    resp_body
  end

  describe "POST /payments" do
    test "with raw data" do
      resp = "payments"
      |> post!(construct_payment())
      |> assert_payment()

      assert %{
        "meta" => %{
          "code" => 201
        },
        "data" => %{
          "recipient" => %{"credential" => %{"type" => "card-number", "number" => "473959******3611"}},
          "sender" => %{"credential" => %{"type" => "card", "number" => "473959******3611"}}
        }
      } = resp
    end

    test "with card token" do
      %{"data" => %{"token" => token}} = "tokens"
      |> post!(@card_credential)
      |> get_body

      resp = "payments"
      |> post!(construct_payment(%{type: "card-token", token: token}))
      |> assert_payment()

      assert %{
        "meta" => %{
          "code" => 201
        },
        "data" => %{
          "recipient" => %{"credential" => %{"type" => "card-number", "number" => "473959******3611"}},
          "sender" => %{"credential" => %{"type" => "card", "number" => "473959******3611"}}
        }
      } = resp
    end

    test "with invalid card token" do
      resp = "payments"
      |> post!(construct_payment(%{type: "card-token", token: "invalid_token"}))
      |> get_body()

      assert %{
        "meta" => %{
          "code" => 422
        },
        "error" => %{
          "invalid" => [
            %{"entry" => "$.sender.credential.token",
              "rules" => [%{"params" => [], "rule" => "token"}]}
          ],
        }
      } = resp
    end

    test "with invalid credential type" do
      resp = "payments"
      |> post!(construct_payment(
        %{type: "card-number", number: "5473959513413611"},
        %{type: "card", number: "5473959513413611", cvv: "160", expiration_month: "01", expiration_year: "2020"}
      ))
      |> get_body

      assert %{
        "meta" => %{
          "code" => 422
        },
        "error" => %{
          "invalid" => [
            %{"entry" => "$.recipient.credential",
              "rules" => [%{"params" => ["card-number", "external-credential"], "rule" => "inclusion"}]},
            %{"entry" => "$.sender.credential",
              "rules" => [%{"params" => ["card", "card-token"], "rule" => "inclusion"}]}
          ],
          "message" => _,
          "type" => "validation_failed"
        }
      } = resp
    end

    test "with invalid card data" do
      resp = "payments"
      |> post!(construct_payment(
        %{type: "card", number: "5473959513413611", cvv: "160", expiration_month: "01", expiration_year: "20"},
        %{type: "card-number", number: "1473959513413611"}
      ))
      |> get_body

      assert %{
        "meta" => %{
          "code" => 422
        },
        "error" => %{
          "invalid" => [
            %{"entry" => "$.recipient.credential.number",
              "rules" => [%{"params" => [], "rule" => "card_number"}]},
            %{"entry" => "$.sender.credential.expiration_year",
              "rules" => [%{"params" => ["~r/^20[12][0-9]$/"], "rule" => "format"}]}
          ],
          "message" => _,
          "type" => "validation_failed"
        }
      } = resp
    end
  end

  describe "GET /payments/:id" do
    test "200" do
      %{"data" => %{"id" => id, "token" => token}} = "payments"
      |> post!(construct_payment())
      |> get_body()

      path = "payments/" <> to_string(id) <> "?token=" <> token

      path
      |> get!
      |> assert_payment
    end

    test "401 when token is invalid" do
      %{"data" => %{"id" => id}} = "payments"
      |> post!(construct_payment())
      |> get_body()

      path = "payments/" <> to_string(id) <> "?token=invalid_token"

      %{"meta" => %{"code" => 401},
        "error" => %{"type" => "access_denied"}} = path
      |> get!
      |> get_body
    end

    test "404 for non-existent payments" do
      path = "payments/0?token=unknown"

      %{"meta" => %{"code" => 404}} = path
      |> get!
      |> get_body
    end

  end
end
