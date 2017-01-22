defmodule Processing.Adapter do
  @moduledoc """
  This module provides behavior that should be implemented by processing layer adapters.
  """

  # @callback send(transfer :: Repo.Schemas.Peer, recipient :: Repo.Schemas.Peer) :: {:ok, }
  # @callback get(transfer :: Repo.Schemas.Peer, recipient :: Repo.Schemas.Peer) :: {:ok, }
  # @callback claim(transfer :: Repo.Schemas.Peer, recipient :: Repo.Schemas.Peer) :: {:ok, }
  # @callback child_spec()
end
