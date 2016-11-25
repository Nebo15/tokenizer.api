defmodule API.Endpoint do
  @moduledoc """
  Phoenix Endpoint for gateway_api application.
  """
  use Phoenix.Endpoint, otp_app: :gateway_api
  require Logger

  # Allow acceptance tests to run in concurrent mode
  if Confex.get(:gateway_api, :sql_sandbox) do
    plug Phoenix.Ecto.SQL.Sandbox
  end

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Logger

  plug EView
  plug EView.Plugs.Idempotency

  plug Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Poison

  plug Plug.MethodOverride
  plug Plug.Head

  plug Corsica, origins: "*"

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug Plug.Session,
    store: :cookie,
    key: "_gateway_api_key",
    signing_salt: "8kcKfWSU"

  plug API.Router
end
