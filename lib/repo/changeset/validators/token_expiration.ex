defmodule Repo.Changeset.Validators.TokenExpiration do
  @moduledoc """
  Validates tokens `expires_at` values.
  """
  import Ecto.Changeset

  def validate_token_expiration(changeset, field, opts \\ []) do
    validate_change changeset, field, :token_expiration, fn _, value ->
      case Timex.compare(Timex.now, value) do
        -1 -> []
        _ -> [{field, {message(opts, "card token is expired"), [validation: :token_expiration]}}]
      end
    end
  end

  defp message(opts, key \\ :message, default) do
    Keyword.get(opts, key, default)
  end
end
