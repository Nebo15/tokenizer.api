defmodule Tokenizer do
  @moduledoc """
  This is an entry point of tokenizer_api application.
  """

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Start the Ecto repository
      supervisor(Tokenizer.DB.Repo, []),
      # Start the endpoint
      supervisor(Tokenizer.HTTP.Endpoint, []),
      # Start the card storage
      supervisor(Tokenizer.CardStorage.Supervisor, []),
    ]

    opts = [strategy: :one_for_one, name: Tokenizer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Tokenizer.HTTP.Endpoint.config_change(changed, removed)
    :ok
  end
end
