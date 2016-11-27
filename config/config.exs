# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure for your application as:
#
#     config :gateway_api, key: :value
#
# And access this configuration in your application as:
#
#     Application.get_env(:gateway_api, :key)
#
# Or configure a 3rd-party app:
#
#     config :logger, level: :info
#
# Or read environment variables in runtime (!) as:
#
#     :var_name, "${ENV_VAR_NAME}"

# Configure your database
config :gateway_api, API.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "gateway_api_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration

config :gateway_api,
  namespace: API,
  ecto_repos: [API.Repo]

# Configures the endpoint
config :gateway_api, API.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "GJq0cIAxm5Egzg5lpPOibBooSTLWa3qfgoDGRsMpXDCjFkLK3uyTf4wICdyJ6W0Y",
  render_errors: [view: EView.Views.PhoenixError, accepts: ~w(json)]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Card token life period
config :gateway_api,
  card_token_expires_in: {:system, :integer, "CARD_TOKEN_EXPIRES_IN", 900_000} # 15 minutes

config :gateway_api,
  card_data_encryption_key: {:system, "CARD_DATA_ENCRYPTION_KEY", "7AHw1Xitrf/YpLsL"}

config :gateway_api,
  :transfer_token_expires_in, {:system, :integer, "PAYMENT_TOKEN_EXPIRES_IN", 900_000} # 15 minutes

config :gateway_api,
  :claim_token_expires_in, {:system, :integer, "PAYMENT_TOKEN_EXPIRES_IN", 900_000} # 15 minutes

config :gateway_api, :limits, # TODO: Move to envs
  amount: [
    min: 1,
    max: 15_000
  ]

config :gateway_api, :fees, [ # TODO: Move to envs
    percent: 0.5,
    fix: 5,
    min: 5,
    max: :infinity
  ]

config :gateway_api, :pay2you,
  upstream_url: "http://p2y-dev.mbill.co/pay2you-ext",
  upstream_version: "0.5.0.b",
  project: [
    name: "bluesky",
    fee: [
      percent: 0.5,
      fix: 5
    ]
  ]

# Authorized consumers
config :gateway_api, :consumer_tokens, [
    {:system, "CONSUMER_TOKEN", "DGRsMpXDCj"}
  ]

# TODO: webhook updates on transfer status changes
config :gateway_api, :webhooks,
  transfer_status: "http://example.com/"

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
import_config "#{Mix.env}.exs"
