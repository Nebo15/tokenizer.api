defmodule Tokenizer.DB.Changeset.Validators.Fee do
  @moduledoc """
  This helper validates phone numbers in international format (with `+:country_code`).
  """
  import Ecto.Changeset

  # TODO
  def validate_fee(changeset, _amount_field, _fee_filed, opts \\ []) do
    changeset
  end

  # defp message(opts, key \\ :message, default) do
  #   Keyword.get(opts, key, default)
  # end
end
