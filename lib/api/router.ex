defmodule API.Router do
  @moduledoc """
  The router provides a set of macros for generating routes
  that dispatch to specific controllers and actions.
  Those macros are named after HTTP verbs.

  More info at: https://hexdocs.pm/phoenix/Phoenix.Router.html
  """
  use Phoenix.Router

  pipeline :public_api do
    plug :accepts, ["json"]
    plug :put_secure_browser_headers
  end

  pipeline :private_api do
    plug :accepts, ["json"]
    plug :put_secure_browser_headers
    plug API.Plugs.Authentification
  end

  scope "/", API.Controllers do
    pipe_through :public_api

    # Create card tokens
    post "/tokens", Token, :create
  end

  scope "/transfers", API.Controllers do
    pipe_through :private_api

    # Create and get transfer
    post "/", Transfer, :create
    get  "/:id", Transfer, :show

    # Complete transfers
    post "/:id/auth", Transfer, :authentificate
  end

  # scope "/claims", API.Controllers do
  #   pipe_through :private_api

  #   # Create and get transfer
  #   post "/", Transfer, :create
  #   get  "/:id", Transfer, :show

  #   # Complete transfers
  #   post "/:id/auth", Transfer, :authentificate
  # end
end
