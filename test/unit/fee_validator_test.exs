defmodule Tokenizer.DB.Changeset.Validators.FeeTest do
  use ExUnit.Case, async: true
  alias Tokenizer.DB.Changeset.Validators.Fee

  @fees [
    {1, 5.01},
    {9, 5.05},
    {10, 5.05},
    {13.5, 5.07},
    {50, 5.25},
    {500, 7.5},
  ]

  test "calculates fee" do
    for {amount, fee} <- @fees,
      do: assert Decimal.equal?(Decimal.new(fee), Fee.calculate(Decimal.new(amount), 0.5, 5, 0, :infinity))
  end
end
