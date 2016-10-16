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
#     config :tokenizer_api, key: :value
#
# And access this configuration in your application as:
#
#     Application.get_env(:tokenizer_api, :key)
#
# Or configure a 3rd-party app:
#
#     config :logger, level: :info
#
# Or read environment variables in runtime (!) as:
#
#     :var_name, "${ENV_VAR_NAME}"

# Configure your database
config :tokenizer_api, Tokenizer.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "tokenizer_api_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration

config :tokenizer_api,
  namespace: Tokenizer,
  ecto_repos: [Tokenizer.Repo]

# Configures the endpoint
config :tokenizer_api, Tokenizer.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "GJq0cIAxm5Egzg5lpPOibBooSTLWa3qfgoDGRsMpXDCjFkLK3uyTf4wICdyJ6W0Y",
  render_errors: [view: Tokenizer.ErrorView, accepts: ~w(json)]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Card token life period
config :tokenizer_api,
  token_expiration_time: 1_800_000 # 30 minutes

config :tokenizer_api,
  card_encryption_key: "7AHw1Xitrf/YpLsL"

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
import_config "#{Mix.env}.exs"
