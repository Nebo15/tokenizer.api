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

    # You can allow JSONP requests by uncommenting this line:
    # plug :allow_jsonp
  end

  scope "/", Tokenizer.Controllers do
    pipe_through :api

    # Create card tokens
    post "/tokens", Token, :create

    # # Create and get payment
    post "/payments", Payment, :create
    get  "/payments/:id", Payment, :show

    # # Complete payments
    # post "/payments/:id/complete", Payment, :complete
  end
end
