defmodule Tokenizer.Controllers.PaymentTest do
  use EView.AcceptanceCase,
    async: true,
    otp_app: :tokenizer_api,
    endpoint: Tokenizer.HTTP.Endpoint,
    repo: Tokenizer.DB.Repo

  @payment_raw %{
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
        number: "5473959513413611"
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

  test "create payment with raw card data" do
    assert %{
      "meta" => %{
        "code" => 201
      },
      "data" => %{
        "id" => _,
        "amount" => "1000",
        "fee" => "10",
        "auth" => %{"acs_url" => nil, "md" => nil, "pa_req" => nil, "terminal_url" => nil, "type" => "3d_secure"},
        "description" => "some content",
        "external_id" => "007",
        "status" => "authorization",
        "token" => _,
        "token_expires_at" => _,
        "type" => "payment",
        "metadata" => %{"feel_free" => "to set any metadata"},
        "recipient" => %{"credential" => %{"type" => "card-number", "number" => "473959******3611"},
                         "email" => "ivan@example.com",
                         "phone" => "+380631112233"},
        "sender" => %{"credential" => %{"type" => "card", "number" => "473959******3611"},
                      "email" => "ivan@example.com",
                      "phone" => "+380631112233"},
        "created_at" => _,
        "updated_at" => _
      }
    } = "payments"
    |> post!(@payment_raw)
    |> get_body
  end

  test "cant sent payment with invalid credential type" do
    assert %{
      "meta" => %{
        "code" => 422
      },
      "error" => %{
        "invalid" => [
          %{"entry" => "$.recipient.credential",
            "entry_type" => "json_data_property",
            "rules" => [%{"params" => ["card-number", "external-credential"], "rule" => "inclusion"}]},
          %{"entry" => "$.sender.credential",
            "entry_type" => "json_data_property",
            "rules" => [%{"params" => ["card", "card-token"], "rule" => "inclusion"}]}
        ],
        "message" => _,
        "type" => "validation_failed"
      }
    } = "payments"
    |> post!(@payment_raw_invalid_type)
    |> get_body
  end

  test "create payment with invalid card data" do
    assert %{
      "meta" => %{
        "code" => 422
      },
      "error" => %{
        "invalid" => [
          %{"entry" => "$.recipient.credential.number",
            "entry_type" => "json_data_property",
            "rules" => [%{"params" => [], "rule" => "card_number"}]},
          %{"entry" => "$.sender.credential.expiration_year",
            "entry_type" => "json_data_property",
            "rules" => [%{"params" => ["~r/^20[12][0-9]$/"], "rule" => "format"}]}
        ],
        "message" => _,
        "type" => "validation_failed"
      }
    } = "payments"
    |> post!(@payment_raw_invalid)
    |> get_body
  end

  test "get payment" do
    assert %{
      "meta" => %{
        "code" => 201
      },
      "data" => %{
        "id" => id,
        "amount" => "1000",
        "fee" => "10",
        "auth" => %{"acs_url" => nil, "md" => nil, "pa_req" => nil, "terminal_url" => nil, "type" => "3d_secure"},
        "description" => "some content",
        "external_id" => "007",
        "status" => "authorization",
        "token" => token,
        "token_expires_at" => _,
        "type" => "payment",
        "metadata" => %{"feel_free" => "to set any metadata"},
        "recipient" => %{"credential" => %{"type" => "card-number", "number" => "473959******3611"},
                         "email" => "ivan@example.com",
                         "phone" => "+380631112233"},
        "sender" => %{"credential" => %{"type" => "card", "number" => "473959******3611"},
                      "email" => "ivan@example.com",
                      "phone" => "+380631112233"},
        "created_at" => _,
        "updated_at" => _
      }
    } = "payments"
    |> post!(@payment_raw)
    |> get_body

    assert %{
      "meta" => %{
        "code" => 200
      },
      "data" => %{
        "id" => _,
        "amount" => "1000" <> _,
        "fee" => "10" <> _,
        "auth" => %{"acs_url" => nil, "md" => nil, "pa_req" => nil, "terminal_url" => nil, "type" => "3d_secure"},
        "description" => "some content",
        "external_id" => "007",
        "status" => "authorization",
        "token" => _,
        "token_expires_at" => _,
        "type" => "payment",
        "metadata" => %{"feel_free" => "to set any metadata"},
        "recipient" => %{"credential" => %{"type" => "card-number", "number" => "473959******3611"},
                         "email" => "ivan@example.com",
                         "phone" => "+380631112233"},
        "sender" => %{"credential" => %{"type" => "card", "number" => "473959******3611"},
                      "email" => "ivan@example.com",
                      "phone" => "+380631112233"},
        "created_at" => _,
        "updated_at" => _
      }
    } = "payments/" <> to_string(id) <> "?token=" <> token
    |> get!
    |> get_body
  end
end
