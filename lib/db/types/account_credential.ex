defmodule Tokenizer.DB.Types.AccountCredential do
  use Tokenizer.DB.Types.DynamicEmbed

  # @doc """
  # Returns related struct based on data structure.
  # """
  def resolve(%{type: "card"}),
    do: {:ok, Tokenizer.DB.Models.Card}
  def resolve(%{type: "card-number"}),
    do: {:ok, Tokenizer.DB.Models.CardNumber}
  def resolve(%{type: "card-token"}),
    do: {:ok, Tokenizer.DB.Models.CardToken}
  def resolve(%{type: "external-credential"}),
    do: {:ok, Tokenizer.DB.Models.ExternalCredential}
  def resolve(_),
    do: {:error, :unkown_type}
end
