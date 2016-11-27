defmodule Processing.Adapter do
  @moduledoc """
  This module provides behavior that should be implemented by processing layer adapters.
  """

  # @callback send(transfer :: API.Repo.Schemas.Peer, recipient :: API.Repo.Schemas.Peer) :: {:ok, }
  # @callback get(transfer :: API.Repo.Schemas.Peer, recipient :: API.Repo.Schemas.Peer) :: {:ok, }
  # @callback claim(transfer :: API.Repo.Schemas.Peer, recipient :: API.Repo.Schemas.Peer) :: {:ok, }
  # @callback child_spec()
end
