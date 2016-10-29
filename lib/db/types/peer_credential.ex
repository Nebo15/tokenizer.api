defmodule Tokenizer.DB.Types.PeerCredential do
  @moduledoc """
  Dynamic embed type for `peer.credential` field.
  """
  use Tokenizer.DB.Types.DynamicEmbed

  @doc """
  Returns related struct based on data structure.
  """
  def resolve(%{type: "card"}),
    do: {:ok, Tokenizer.DB.Schemas.Card}
  def resolve(%{type: "card-number"}),
    do: {:ok, Tokenizer.DB.Schemas.CardNumber}
  def resolve(%{type: "card-token"}),
    do: {:ok, Tokenizer.DB.Schemas.CardToken}
  def resolve(%{type: "external-credential"}),
    do: {:ok, Tokenizer.DB.Schemas.ExternalCredential}
  def resolve(_),
    do: {:error, :unkown_type}
end
