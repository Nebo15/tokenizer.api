defmodule Gateway do
  @moduledoc """
  This is an entry point of gateway_api application.
  """
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Start the card tokenization
      supervisor(Tokenizer.Supervisor, []),
      # Start REST API
      supervisor(API.Supervisor, []),
    ]

    opts = [strategy: :one_for_one, name: Gateway.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    API.Endpoint.config_change(changed, removed)
    :ok
  end
end
