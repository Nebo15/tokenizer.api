defmodule Repo.Types.Authorization do
  @moduledoc """
  Dynamic embed type for `transfer.auth` field.
  """
  use Repo.Types.DynamicEmbed

  @doc """
  Returns related struct based on data structure.
  """
  def resolve(%{type: "3d-secure"}),
    do: {:ok, Repo.Schemas.Authorization3DS}
  def resolve(%{type: "lookup-code"}),
    do: {:ok, Repo.Schemas.AuthorizationLookupCode}
  def resolve(_),
    do: {:error, :unkown_type}

  @doc """
  Returns list of supported `type`'s.
  """
  def types, do: ["3d-secure", "lookup-code"]
end
