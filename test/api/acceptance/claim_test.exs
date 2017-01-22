defmodule API.Controllers.ClaimTest do
  use EView.AcceptanceCase,
    async: true,
    otp_app: :gateway_api,
    endpoint: API.Endpoint,
    repo: Repo,
    headers: [{"content-type", "application/json"}]

  @card_credential %{
    type: "card",
    number: "5591587543706253",
    cvv: "160",
    expiration_month: "01",
    expiration_year: "2020"
  }

  @card_number_credential %{
    type: "card-number",
    number: "5473959513413611"
  }

  defp construct_claim(external_id, credential \\ @card_number_credential) do
    %{
      external_id: external_id,
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
    %{"data" => %{"id" => id, "token" => token}} = "transfers"
    |> post!(%{
      amount: 1000,
      fee: "10",
      sender: %{
        phone: "+380631112233",
        credential: @card_credential
      },
      recipient: %{
        phone: "+380631112233",
        email: "ivan@example.com",
        credential: %{
          type: "external-credential"
        }
      }
    })
    |> get_body()

    path = "transfers/" <> to_string(id) <> "/auth"

    transfer = path
    |> post!(%{"code" => 123456}, [{"authorization", "Basic " <> Base.encode64(token <> ":")}])
    |> get_body()

    %{transfer: transfer, claim_id: transfer["data"]["recipient"]["credential"]["id"]}
  end

  describe "POST /claims" do
    test "with raw data", %{claim_id: claim_id} do
      resp = "claims"
      |> post!(construct_claim(claim_id))
      |> assert_claim()

      assert %{
        "meta" => %{
          "code" => 201
        },
        "data" => %{
          "credential" => %{"type" => "card-number", "number" => "547395******3611"}
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
            %{"entry" => "$.external_id",
              "rules" => [%{"params" => [], "rule" => "claim_id"}]}
          ],
        }
      } = resp
    end

    test "with invalid credential type", %{claim_id: claim_id} do
      resp = "claims"
      |> post!(construct_claim(claim_id, %{type: "card-token", token: "invalid_token"}))
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

    test "with invalid card data", %{claim_id: claim_id} do
      resp = "claims"
      |> post!(construct_claim(claim_id, %{type: "card-number", number: "1473959513413611"}))
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
    test "200", %{claim_id: claim_id} do
      %{"data" => %{"id" => id, "token" => token}} = "claims"
      |> post!(construct_claim(claim_id))
      |> get_body()

      path = "claims/" <> to_string(id)

      path
      |> get!([{"authorization", "Basic " <> Base.encode64(token <> ":")}])
      |> assert_claim()
    end

    test "401 when token is invalid", %{claim_id: claim_id} do
      %{"data" => %{"id" => id}} = "claims"
      |> post!(construct_claim(claim_id))
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
    test "201", %{claim_id: claim_id} do
      %{"data" => %{"id" => id, "token" => token}} = "claims"
      |> post!(construct_claim(claim_id))
      |> get_body()

      path = "claims/" <> to_string(id) <> "/auth"

      {claim_id, _} = Integer.parse(claim_id)

      assert %{
        "meta" => %{
          "code" => _
        },
        "data" => %{"status" => "processing"}
      } = path
      |> post!(
        %{"type" => "otp-code", "code" => claim_id + 1},
        [{"authorization", "Basic " <> Base.encode64(token <> ":")}]
      )
      |> get_body()

      path = "claims/" <> to_string(id)

      assert %{
        "meta" => %{
          "code" => _
        },
        "data" => %{"status" => "completed"}
      } = path
      |> get!([{"authorization", "Basic " <> Base.encode64(token <> ":")}])
      |> get_body()
    end

    test "422 for invalid otp tokens", %{claim_id: claim_id} do
      %{"data" => %{"id" => id, "token" => token}} = "claims"
      |> post!(construct_claim(claim_id))
      |> get_body()

      path = "claims/" <> to_string(id) <> "/auth"

      assert %{
        "meta" => %{
          "code" => 422
        },
        "error" => %{
          "invalid" => [
            %{"entry" => "$.code",
              "rules" => [%{"params" => [], "rule" => "otp_code"}]}
          ],
        }
      } = path
      |> post!(
        %{"type" => "otp-code", "code" => 123123},
        [{"authorization", "Basic " <> Base.encode64(token)}]
      )
      |> get_body()
    end

    test "401 when token is invalid", %{claim_id: claim_id} do
      %{"data" => %{"id" => id}} = "claims"
      |> post!(construct_claim(claim_id))
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
