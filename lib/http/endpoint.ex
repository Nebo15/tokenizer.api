defmodule Tokenizer.HTTP.Endpoint do
  @moduledoc """
  Phoenix Endpoint for tokenizer_api application.
  """

  use Phoenix.Endpoint, otp_app: :tokenizer_api
  require Logger

  # Allow acceptance tests to run in concurrent mode
  if Confex.get(:tokenizer_api, :sql_sandbox) do
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
  plug EView.IdempotencyPlug

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison

  plug Plug.MethodOverride
  plug Plug.Head

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug Plug.Session,
    store: :cookie,
    key: "_tokenizer_api_key",
    signing_salt: "8kcKfWSU"

  plug Tokenizer.Router
end
