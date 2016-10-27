defmodule Tokenizer.DB.Changeset.Validators.EmbedType do
  @moduledoc """
  This validator allows to check embed type inclusion in a whitelist.
  """
  import Ecto.Changeset

  def validate_embed_type(changeset, field, types, opts \\ []) do
    validate_change changeset, field, {:inclusion, types}, fn _, value ->
      case value.data.type in types do
        true -> []
        false -> [{field, {message(opts, "this type is not allowed"), [validation: :inclusion]}}]
      end
    end
  end

  defp message(opts, key \\ :message, default) do
    Keyword.get(opts, key, default)
  end
end
