defmodule Tokenizer.DB.Types.Authorization do
  use Tokenizer.DB.Types.DynamicEmbed

  # @doc """
  # Returns related struct based on data structure.
  # """
  def resolve(%{type: "3d_secure"}),
    do: {:ok, Tokenizer.DB.Models.Authorization3DS}
  def resolve(%{type: "lookup_code"}),
    do: {:ok, Tokenizer.DB.Models.AuthorizationLookupCode}
  def resolve(_),
    do: {:error, :unkown_type}
end
