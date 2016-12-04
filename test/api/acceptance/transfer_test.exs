defmodule API.Controllers.TransferTest do
  use EView.AcceptanceCase,
    async: true,
    otp_app: :gateway_api,
    endpoint: API.Endpoint,
    repo: API.Repo,
    headers: [{"content-type", "application/json"}]

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

  defp construct_transfer(sender_credential \\ @card_credential, recipient_credential \\ @card_number_credential) do
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

  defp assert_transfer(resp) do
    resp_body = get_body(resp)

    assert %{
      "meta" => %{
        "code" => _
      },
      "data" => %{
        "id" => _,
        "amount" => _,
        "fee" => _,
        "auth" => _, # TODO: check authorization
        "description" => "some content",
        "external_id" => _,
        "status" => "authentication",
        "token" => _,
        "token_expires_at" => _,
        "type" => "transfer",
        "metadata" => %{"feel_free" => "to set any metadata"},
        "recipient" => %{"credential" => _, "email" => "ivan@example.com", "phone" => "+380631112233"},
        "sender" => %{"credential" => _, "email" => "ivan@example.com", "phone" => "+380631112233"},
        "created_at" => _,
        "updated_at" => _
      }
    } = resp_body

    resp_body
  end

  describe "POST /transfers" do
    test "with raw data" do
      resp = "transfers"
      |> post!(construct_transfer())
      |> assert_transfer()

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

    test "with sender card token" do
      %{"data" => %{"token" => token}} = "tokens"
      |> post!(@card_credential)
      |> get_body()

      resp = "transfers"
      |> post!(construct_transfer(%{type: "card-token", token: token}))
      |> assert_transfer()

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

    # test "with recipient card token" do
    #   %{"data" => %{"token" => token}} = "tokens"
    #   |> post!(@card_credential)
    #   |> get_body

    #   resp = "transfers"
    #   |> post!(construct_transfer(@card_credential, %{type: "card-token", token: token}))
    #   |> assert_transfer()

    #   assert %{
    #     "meta" => %{
    #       "code" => 201
    #     },
    #     "data" => %{
    #       "recipient" => %{"credential" => %{"type" => "card", "number" => "473959******3611"}},
    #       "sender" => %{"credential" => %{"type" => "card", "number" => "473959******3611"}}
    #     }
    #   } = resp
    # end

    test "with invalid card token" do
      resp = "transfers"
      |> post!(construct_transfer(%{type: "card-token", token: "invalid_token"}))
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

    # TODO with unknown token type it generates cast error with Elixir module name
    test "with unsupported credential type" do
      resp = "transfers"
      |> post!(construct_transfer(%{type: "bitcoin", number: "5473959513413611"}))
      |> get_body()

      assert %{
        "meta" => %{
          "code" => 422
        },
        "error" => %{
          "invalid" => [
            %{"entry" => "$.sender.credential",
              "rules" => [%{"params" => ["card", "card-token"], "rule" => "inclusion"}]}
          ],
          "message" => _,
          "type" => "validation_failed"
        }
      } = resp
    end

    test "with invalid credential type" do
      resp = "transfers"
      |> post!(construct_transfer(
        %{type: "card-number", number: "5473959513413611"},
        %{type: "card", number: "5473959513413611", cvv: "160", expiration_month: "01", expiration_year: "2020"}
      ))
      |> get_body()

      assert %{
        "meta" => %{
          "code" => 422
        },
        "error" => %{
          "invalid" => [
            %{"entry" => "$.recipient.credential",
              "rules" => [%{"params" => ["card-number", "card-token", "external-credential"], "rule" => "inclusion"}]},
            %{"entry" => "$.sender.credential",
              "rules" => [%{"params" => ["card", "card-token"], "rule" => "inclusion"}]}
          ],
          "message" => _,
          "type" => "validation_failed"
        }
      } = resp
    end

    test "with invalid card data" do
      resp = "transfers"
      |> post!(construct_transfer(
        %{type: "card", number: "5473959513413611", cvv: "160", expiration_month: "01", expiration_year: "20"},
        %{type: "card-number", number: "1473959513413611"}
      ))
      |> get_body()

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

  describe "GET /transfers/:id" do
    test "200" do
      %{"data" => %{"id" => id, "token" => token}} = "transfers"
      |> post!(construct_transfer())
      |> get_body()

      path = "transfers/" <> to_string(id)

      path
      |> get!([{"authorization", "Basic " <> Base.encode64(token <> ":")}])
      |> assert_transfer()
    end

    test "401 when token is invalid" do
      %{"data" => %{"id" => id}} = "transfers"
      |> post!(construct_transfer())
      |> get_body()

      path = "transfers/" <> to_string(id)

      %{"meta" => %{"code" => 401},
        "error" => %{"type" => "access_denied"}} = path
      |> get!([{"authorization", "Basic " <> Base.encode64("invalid_token:")}])
      |> get_body()
    end

    test "404 for non-existent transfers" do
      path = "transfers/0"

      # With auth header
      %{"meta" => %{"code" => 404}} = path
      |> get!([{"authorization", "Basic " <> Base.encode64("invalid_token:")}])
      |> get_body()

      # Without auth header
      %{"meta" => %{"code" => 404}} = path
      |> get!()
      |> get_body()
    end
  end

  describe "POST /transfers/:id/auth" do
    test "201" do
      %{"data" => %{"id" => id, "token" => token}} = "transfers"
      |> post!(construct_transfer(%{
        type: "card",
        number: "5591587543706253",
        cvv: "160",
        expiration_month: "01",
        expiration_year: "2020"
      }))
      |> get_body()

      path = "transfers/" <> to_string(id) <> "/auth"

      assert %{
        "meta" => %{
          "code" => _
        },
        "data" => %{"status" => "processing"}
      } = path
      |> post!(%{"code" => 123456}, [{"authorization", "Basic " <> Base.encode64(token)}])
      |> get_body()
    end

    test "401 when token is invalid" do
      %{"data" => %{"id" => id}} = "transfers"
      |> post!(construct_transfer())
      |> get_body()

      path = "transfers/" <> to_string(id)

      %{"meta" => %{"code" => 401},
        "error" => %{"type" => "access_denied"}} = path
      |> get!([{"authorization", "Basic " <> Base.encode64("invalid_token")}])
      |> get_body()
    end

    test "404 for non-existent transfers" do
      path = "transfers/0/auth"

      # With auth header
      %{"meta" => %{"code" => 404}} = path
      |> get!([{"authorization", "Basic " <> Base.encode64("invalid_token:")}])
      |> get_body()

      # Without auth header
      %{"meta" => %{"code" => 404}} = path
      |> get!()
      |> get_body()
    end
  end
end
