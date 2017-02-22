defmodule Tokenizer.SupervisorTest do
  use ExUnit.Case
  alias Repo.Schemas.Card
  alias Tokenizer.Supervisor, as: Tokenizer

  @card %Card{
    number: "5591587543706253",
    expiration_month: "01",
    expiration_year: "2020",
    cvv: "160"
  }

  test "generates tokens" do
    assert <<"card-token-", last4::bytes-size(4), "-", _token::binary>> = @card.number
    |> Tokenizer.generate_token

    assert ^last4 = String.slice(@card.number, -4..-1)
  end

  test "stores card data" do
    assert {:ok, %{token: token, token_expires_at: _}} = Tokenizer.save_card(@card)
    assert {:ok, @card} = Tokenizer.get_card(token)
    :timer.sleep(100)
    assert {:error, :card_not_found} = Tokenizer.get_card(token)
  end

  test "deletes expired tokens" do
    Application.put_env(:gateway_api, :card_token_expires_in, 10)

    assert {:ok, %{token: token, token_expires_at: _}} = Tokenizer.save_card(@card)
    :timer.sleep(100)
    assert {:error, :card_not_found} = Tokenizer.get_card(token)

    on_exit(fn ->
      Application.put_env(:gateway_api, :card_token_expires_in, 15_000)
    end)
  end
end
