defmodule Tokenizer.DB.Types.Authorization do
  @moduledoc """
  Dynamic embed type for `payment.auth` field.
  """
  use Tokenizer.DB.Types.DynamicEmbed

  # @doc """
  # Returns related struct based on data structure.
  # """
  def resolve(%{type: "3d-secure"}),
    do: {:ok, Tokenizer.DB.Schemas.Authorization3DS}
  def resolve(%{type: "lookup-code"}),
    do: {:ok, Tokenizer.DB.Schemas.AuthorizationLookupCode}
  def resolve(_),
    do: {:error, :unkown_type}
end
