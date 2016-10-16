use Mix.Config

# Configuration for test environment


# Configure your database
config :tokenizer_api, Tokenizer.Repo,
  pool: Ecto.Adapters.SQL.Sandbox,
  database: "tokenizer_api_test"

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :tokenizer_api, Tokenizer.Endpoint,
  http: [port: 4001],
  server: true

# Print only warnings and errors during test
config :logger, level: :warn

# Run acceptance test in concurrent mode
config :tokenizer_api, sql_sandbox: true
