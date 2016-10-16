defmodule Tokenizer do
  @moduledoc """
  This is an entry point of tokenizer_api application.
  """

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Start the Ecto repository
      supervisor(Tokenizer.Repo, []),
      # Start the endpoint when the application starts
      supervisor(Tokenizer.Endpoint, []),
      # Start card storage
      supervisor(Tokenizer.CardStorage.Supervisor, []),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Tokenizer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Tokenizer.Endpoint.config_change(changed, removed)
    :ok
  end
end
