defmodule API.Supervisor do
  @moduledoc """
  This is an entry point of REST API interface.
  """
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc false
  def init(_) do
    children = [
      # Start the Ecto repository
      supervisor(Repo, []),
      # Start the endpoint
      supervisor(API.Endpoint, []),
    ]

    supervise(children, strategy: :one_for_one)
  end
end
