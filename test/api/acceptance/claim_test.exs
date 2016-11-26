defmodule API.Controllers.ClaimTest do
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

  @valid_claim_id "123456"

  defp construct_claim(id \\ @valid_claim_id, credential \\ @card_number_credential) do
    %{
      id: id,
      credential: credential
    }
  end

  defp assert_claim(resp) do
    resp_body = get_body(resp)

    assert %{
      "meta" => %{
        "code" => _
      },
      "data" => %{
        "id" => _,
        "credential" => _,
        "status" => "authentication",
        "token" => _,
        "token_expires_at" => _,
        "created_at" => _,
        "updated_at" => _,
        "auth" => %{"type" => "otp-code"},
      }
    } = resp_body

    resp_body
  end

  setup do
    transfer = "transfers"
    |> post!(%{
      amount: 1000,
      fee: "10",
      description: "some content",
      metadata: %{
        feel_free: "to set any metadata"
      },
      sender: %{
        phone: "+380631112233",
        email: "ivan@example.com",
        credential: @card_credential
      },
      recipient: %{
        phone: "+380631112233",
        email: "ivan@example.com",
        credential: %{
          type: "external-credential",
          id: @valid_claim_id,
          metadata: %{
            phone: "+380631112233"
          }
        }
      }
    })

    %{transfer: transfer}
  end

  describe "POST /claims" do
    test "with raw data" do
      resp = "claims"
      |> post!(construct_claim())
      |> assert_claim()

      assert %{
        "meta" => %{
          "code" => 201
        },
        "data" => %{
          "credential" => %{"type" => "card-number", "number" => "473959******3611"}
        }
      } = resp
    end

    test "with invalid claim id" do
      resp = "claims"
      |> post!(construct_claim("007"))
      |> get_body()

      assert %{
        "meta" => %{
          "code" => 422
        },
        "error" => %{
          "invalid" => [
            %{"entry" => "$.id",
              "rules" => [%{"params" => [], "rule" => "claim_id"}]}
          ],
        }
      } = resp
    end

    test "with invalid credential type" do
      resp = "claims"
      |> post!(construct_claim(@valid_claim_id, %{type: "card-token", token: "invalid_token"}))
      |> get_body

      assert %{
        "meta" => %{
          "code" => 422
        },
        "error" => %{
          "invalid" => [
            %{"entry" => "$.credential",
              "rules" => [%{"params" => ["card-number"], "rule" => "inclusion"}]}
          ],
          "message" => _,
          "type" => "validation_failed"
        }
      } = resp
    end

    test "with invalid card data" do
      resp = "claims"
      |> post!(construct_claim(@valid_claim_id, %{type: "card-number", number: "1473959513413611"}))
      |> get_body

      assert %{
        "meta" => %{
          "code" => 422
        },
        "error" => %{
          "invalid" => [
            %{"entry" => "$.credential.number",
              "rules" => [%{"params" => [], "rule" => "card_number"}]}
          ],
          "message" => _,
          "type" => "validation_failed"
        }
      } = resp
    end
  end

  describe "GET /claims/:id" do
    test "200" do
      %{"data" => %{"id" => id, "token" => token}} = "claims"
      |> post!(construct_claim())
      |> get_body()

      path = "claims/" <> to_string(id)

      path
      |> get!([{"authorization", "Basic " <> Base.encode64(token <> ":")}])
      |> assert_claim()
    end

    test "401 when token is invalid" do
      %{"data" => %{"id" => id}} = "claims"
      |> post!(construct_claim())
      |> get_body()

      path = "claims/" <> to_string(id)

      %{"meta" => %{"code" => 401},
        "error" => %{"type" => "access_denied"}} = path
      |> get!([{"authorization", "Basic " <> Base.encode64("invalid_token:")}])
      |> get_body()
    end

    test "404 for non-existent claims" do
      path = "claims/0"

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

  describe "POST /claims/:id/auth" do
    test "201" do
      %{"data" => %{"id" => id, "token" => token}} = "claims"
      |> post!(construct_claim())
      |> get_body()

      path = "claims/" <> to_string(id) <> "/auth"

      assert %{
        "meta" => %{
          "code" => _
        },
        "data" => %{"status" => "completed"}
      } = path
      |> post!(%{"type" => "otp-code", "otp-code" => 123456}, [{"authorization", "Basic " <> Base.encode64(token)}])
      |> get_body()
    end

    test "401 when token is invalid" do
      %{"data" => %{"id" => id}} = "claims"
      |> post!(construct_claim())
      |> get_body()

      path = "claims/" <> to_string(id)

      %{"meta" => %{"code" => 401},
        "error" => %{"type" => "access_denied"}} = path
      |> get!([{"authorization", "Basic " <> Base.encode64("invalid_token")}])
      |> get_body()
    end

    test "404 for non-existent claims" do
      path = "claims/0/auth"

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
