defmodule Tokenizer.Router do
  @moduledoc """
  The router provides a set of macros for generating routes
  that dispatch to specific controllers and actions.
  Those macros are named after HTTP verbs.

  More info at: https://hexdocs.pm/phoenix/Phoenix.Router.html
  """

  use Tokenizer.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug :put_secure_browser_headers
    plug Tokenizer.HTTP.Plugs.Authorization
  end

  scope "/", Tokenizer.Controllers do
    pipe_through :api

    # Create card tokens
    post "/tokens", Token, :create

    # Create and get payment
    post "/payments", Payment, :create
    get  "/payments/:id", Payment, :show

    # Complete payments
    # post "/payments/:id/auth", PaymentAuthorization, :authorize
    # post "/payments/:id/claim", Payment, :claim
  end
end
