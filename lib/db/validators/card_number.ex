defmodule Ecto.Changeset.CardValidator do
  @moduledoc """
  This helper validates card number by luhn algorithm.
  """
  def validate_card_number(changeset, field) do
     validate changeset, field, Ecto.Changeset.get_field(changeset, field)
  end

  defp validate(changeset, _, value) when is_nil(value) do
      changeset
  end

  defp validate(changeset, _, value) when is_binary(value) and byte_size(value) == 0 do
      changeset
  end

  defp validate(changeset, field, value) do
    case CreditCard.valid?(value, %{allowed_card_types: [:visa, :master_card]}) do
      true ->
        changeset
      _ ->
        Ecto.Changeset.add_error(changeset, field, "is invalid")
    end
  end
end
