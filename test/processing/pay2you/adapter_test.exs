defmodule Processing.Adapters.Pay2You.AdapterTest do
  use ExUnit.Case, async: true
  alias Processing.Adapters.Pay2You
  alias Repo.Schemas.{Card, CardNumber}

  @lookup_card %Card{
    number: "5591587543706253",
    expiration_month: "01",
    expiration_year: "2020",
    cvv: "160"
  }

  @ds3_card %Card{
    number: "5513877294352240",
    expiration_month: "01",
    expiration_year: "2020",
    cvv: "160"
  }

  @card_number %CardNumber{
    number: "5591587543706253"
  }

  describe "send card2card transfer" do
    test "with lookup authorization" do
      transfer = @lookup_card
      |> Pay2You.Transfer.send(@card_number, Decimal.new(1), Decimal.new(5.01), "+380971112233")

      assert {:ok, transfer_response} = transfer
      assert %{
        auth: %Repo.Schemas.AuthorizationLookupCode{
          md: _,
          type: "lookup-code"
        },
        external_id: _transfer_id,
        status: "authentication"
      } = transfer_response
    end

    test "with 3DS authorization" do
      transfer = @ds3_card
      |> Pay2You.Transfer.send(@card_number, Decimal.new(1), Decimal.new(5.01), "+380971112233")

      assert {:ok, transfer_response} = transfer
      assert %{
        auth: %Repo.Schemas.Authorization3DS{
          acs_url: "http://p2y-dev.mbill.co/pay2you-external/3ds",
          md: _,
          pa_req: _,
          terminal_url: "http://p2y-dev.mbill.co/pay2you-external/3ds/input3d",
          type: "3d-secure"
        },
        external_id: _transfer_id,
        status: "authentication"
      } = transfer_response
    end

    test "with validation error" do
      transfer = %{@lookup_card | number: "1111222233334444"}
      |> Pay2You.Transfer.send(@card_number, Decimal.new(1), Decimal.new(5.01), "+380971112233")

      assert {:error, transfer_response} = transfer
      assert %{
        decline: %{
          code: 11,
          reason: "PAN_Invalid"
        },
        external_id: _transfer_id,
        status: "declined"
      } = transfer_response
    end

    test "with back-end error" do
      transfer = %{@lookup_card | cvv: "1111234"}
      |> Pay2You.Transfer.send(@card_number, Decimal.new(1), Decimal.new(5.01), "+380971112233")

      assert {:error, transfer_response} = transfer
      assert %{
        decline: %{
          code: 6,
          reason: "Card_Expired"
        },
        external_id: _transfer_id,
        status: "declined"
      } = transfer_response
    end
  end

  describe "send card2phone transfer" do
    test "with lookup authorization" do
      transfer = @lookup_card
      |> Pay2You.Transfer.send("+380971112233", Decimal.new(1), Decimal.new(5.01), "+380971112233")

      assert {:ok, transfer_response} = transfer
      assert %{
        auth: %Repo.Schemas.AuthorizationLookupCode{
          md: _,
          type: "lookup-code"
        },
        external_id: _transfer_id,
        status: "authentication"
      } = transfer_response
    end

    test "with 3DS authorization" do
      transfer = @ds3_card
      |> Pay2You.Transfer.send("+380971112233", Decimal.new(1), Decimal.new(5.01), "+380971112233")

      assert {:ok, transfer_response} = transfer
      assert %{
        auth: %Repo.Schemas.Authorization3DS{
          acs_url: "http://p2y-dev.mbill.co/pay2you-external/3ds",
          md: _,
          pa_req: _,
          terminal_url: "http://p2y-dev.mbill.co/pay2you-external/3ds/input3d",
          type: "3d-secure"
        },
        external_id: _transfer_id,
        status: "authentication"
      } = transfer_response
    end

    test "with validation error" do
      transfer = %{@lookup_card | number: "1111222233334444"}
      |> Pay2You.Transfer.send("+380971112233", Decimal.new(1), Decimal.new(5.01), "+380971112233")

      assert {:error, transfer_response} = transfer
      assert %{
        decline: %{
          code: 11,
          reason: "PAN_Invalid"
        },
        external_id: _transfer_id,
        status: "declined"
      } = transfer_response
    end

    test "with back-end error" do
      transfer = %{@lookup_card | cvv: "1111234"}
      |> Pay2You.Transfer.send("+380971112233", Decimal.new(1), Decimal.new(5.01), "+380971112233")

      assert {:error, transfer_response} = transfer
      assert %{
        decline: %{
          code: 6,
          reason: "Card_Expired"
        },
        external_id: _transfer_id,
        status: "declined"
      } = transfer_response
    end
  end

  # describe "authorize transfer via lookup code" do
  #   setup do
  #     {:ok, transfer} = @lookup_card
  #     |> Pay2You.Transfer.send(@card_number, Decimal.new(1), Decimal.new(5.01), "+380971112233")

  #     %{transfer: transfer}
  #   end

  #   test "with valid code", %{transfer: transfer} do
  #     Pay2You.LookupAuth.auth()
  #   end
  # end
end
