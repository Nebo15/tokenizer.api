defmodule Tokenizer.Controllers.TokenTest do
  use EView.AcceptanceCase,
    async: true,
    otp_app: :tokenizer_api,
    endpoint: Tokenizer.HTTP.Endpoint,
    repo: Tokenizer.DB.Repo,
    headers: [{"authorization", "Basic " <> Base.encode64("DGRsMpXDCj:")}]

  alias Tokenizer.DB.Schemas.Card

  @token_prefix "card-token"

  @card %Card{
    number: "5591587543706253",
    expiration_month: "01",
    expiration_year: "2020",
    cvv: "160"
  }

  @invalid_card %Card{
    number: "5591587543706251",
    expiration_month: "12",
    expiration_year: "1997",
    cvv: "11160"
  }

  test "create card" do
    assert %{
      "meta" => %{
        "code" => 201
      },
      "data" => %{
        "type" => "card-token",
        "token" => @token_prefix <> _,
        "token_expires_at" => _
      }
    } = "tokens"
    |> post!(@card)
    |> get_body
  end

  test "create invalid card" do
    assert %{
      "meta" => %{
        "code" => 422
      },
      "error" => _
    } = "tokens"
    |> post!(@invalid_card)
    |> get_body
  end
end
