use Mix.Config

# Configuration for test environment


# Configure your database
config :gateway_api, API.Repo,
  pool: Ecto.Adapters.SQL.Sandbox,
  database: "gateway_api_test"

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :gateway_api, API.Endpoint,
  http: [port: 4001],
  server: true

# Print only warnings and errors during test
config :logger, level: :warn

# Run acceptance test in concurrent mode
config :gateway_api, sql_sandbox: true
