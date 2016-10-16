defmodule Tokenizer.CardStorage.SupervisorTest do
  use ExUnit.Case
  alias Tokenizer.DB.Models.SenderCard
  alias Tokenizer.CardStorage.Supervisor, as: CardStorage

  @card %SenderCard{
    number: "5591587543706253",
    expiration_month: "01",
    expiration_year: "20",
    cvv: "160"
  }

  test "generates tokens" do
    assert <<"token-", last4::bytes-size(4), "-", _token::binary>> = @card.number
    |> CardStorage.generate_token

    assert ^last4 = String.slice(@card.number, -4..-1)
  end

  test "stores card data" do
    assert {:ok, %{token: token, token_expires_at: _}} = CardStorage.save_card(@card)
    assert {:ok, @card} = CardStorage.get_card(token)
    assert {:error, :card_not_found} = CardStorage.get_card(token)
  end

  test "deletes expired tokens" do
    Application.put_env(:tokenizer_api, :token_expiration_time, 10)

    assert {:ok, %{token: token, token_expires_at: _}} = CardStorage.save_card(@card)
    :timer.sleep(100)
    assert {:error, :card_not_found} = CardStorage.get_card(token)

    on_exit(fn ->
      Application.put_env(:tokenizer_api, :token_expiration_time, 15_000)
    end)
  end
end
