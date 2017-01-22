defmodule Repo.Types.PeerCredential do
  @moduledoc """
  Dynamic embed type for `peer.credential` field.
  """
  use Repo.Types.DynamicEmbed

  @doc """
  Returns related struct based on data structure.
  """
  def resolve(%{type: "card"}),
    do: {:ok, Repo.Schemas.Card}
  def resolve(%{type: "card-number"}),
    do: {:ok, Repo.Schemas.CardNumber}
  def resolve(%{type: "card-token"}),
    do: {:ok, Repo.Schemas.CardToken}
  def resolve(%{type: "external-credential"}),
    do: {:ok, Repo.Schemas.ExternalCredential}
  def resolve(_),
    do: {:error, :unkown_type}

  @doc """
  Returns list of supported `type`'s.
  """
  def types, do: ["card", "card-number", "card-token", "external-credential"]
end
