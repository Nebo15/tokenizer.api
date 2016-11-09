defmodule Tokenizer.Router do
  @moduledoc """
  The router provides a set of macros for generating routes
  that dispatch to specific controllers and actions.
  Those macros are named after HTTP verbs.

  More info at: https://hexdocs.pm/phoenix/Phoenix.Router.html
  """

  use Tokenizer.Web, :router

  pipeline :public_api do
    plug :accepts, ["json"]
    plug :put_secure_browser_headers
  end

  pipeline :private_api do
    plug :accepts, ["json"]
    plug :put_secure_browser_headers
    plug Tokenizer.HTTP.Plugs.Authentification
  end

  scope "/", Tokenizer.Controllers do
    pipe_through :public_api

    # Create card tokens
    post "/tokens", Token, :create
  end

  scope "/transfers", Tokenizer.Controllers do
    pipe_through :private_api

    # Create and get transfer
    post "/", Transfer, :create
    get  "/:id", Transfer, :show

    # Complete transfers
    post "/:id/auth", Transfer, :authentificate
  end
end
