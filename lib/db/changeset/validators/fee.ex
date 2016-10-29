defmodule Tokenizer.DB.Changeset.Validators.Fee do
  @moduledoc """
  This helper validates phone numbers in international format (with `+:country_code`).
  """
  import Ecto.Changeset
  alias Decimal, as: D

  defstruct fix: nil, percent: nil, min: 0, max: :infinity

  def validate_fee(changeset, amount_field, fee_field, [percent: percent, fix: fix, min: min, max: max] = opts) do
    validate_change changeset, amount_field, {:fee, opts}, fn _, value ->
      valid_fee = calculate(value, percent, fix, min, max)
      payment_fee = get_field(changeset, fee_field)
      case D.cmp(valid_fee, payment_fee) do
        :eq -> []
        _ -> [{fee_field, {"is invalid, must be #{valid_fee}", [validation: :fee]}}]
      end
    end
  end

  def calculate(amount, percent, fix, min, max) do
    D.set_context(%D.Context{D.get_context | precision: 2, rounding: :half_up})

    amount
    |> calculate_body(percent, fix)
    |> apply_limits(min, max)
  end

  defp calculate_body(amount, percent, fix) do
    D.add(D.mult(amount, D.div(D.new(percent), D.new(100))), D.new(fix))
  end

  defp apply_limits(body, min, :infinity) do
    D.max(body, D.new(min))
  end

  defp apply_limits(body, min, max) do
    D.max(D.min(body, D.new(max)), D.new(min))
  end
end
