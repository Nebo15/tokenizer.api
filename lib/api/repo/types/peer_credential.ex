defmodule API.Repo.Types.PeerCredential do
  @moduledoc """
  Dynamic embed type for `peer.credential` field.
  """
  use API.Repo.Types.DynamicEmbed

  @doc """
  Returns related struct based on data structure.
  """
  def resolve(%{type: "card"}),
    do: {:ok, API.Repo.Schemas.Card}
  def resolve(%{type: "card-number"}),
    do: {:ok, API.Repo.Schemas.CardNumber}
  def resolve(%{type: "card-token"}),
    do: {:ok, API.Repo.Schemas.CardToken}
  def resolve(%{type: "external-credential"}),
    do: {:ok, API.Repo.Schemas.ExternalCredential}
  def resolve(_),
    do: {:error, :unkown_type}
end
