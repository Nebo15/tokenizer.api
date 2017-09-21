defmodule Gateway.Mixfile do
  use Mix.Project

  @version "0.0.13" # ToDo: revert to normal version. Now its test version for new P2Y backend

  def project do
    [app: :gateway_api,
     version: @version,
     elixir: "~> 1.4",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps(),
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: [coveralls: :test],
     docs: [source_ref: "v#\{@version\}", main: "readme", extras: ["README.md"]]]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :phoenix, :phoenix_ecto, :cowboy, :httpoison, :poison, :corsica,
                    :ecto, :postgrex, :timex, :credit_card, :confex, :eview],
     mod: {Gateway, []}]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # To depend on another app inside the umbrella:
  #
  #   {:myapp, in_umbrella: true}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:distillery, "~> 1.2"},
     {:phoenix, "~> 1.2"},
     {:phoenix_ecto, "3.1.0"},
     {:ecto, "~> 2.1"},
     {:postgrex, "~> 0.13.0"},
     {:confex, "~> 1.4"},
     {:eview, "~> 0.10.0"},
     {:cowboy, "~> 1.1"},
     {:poison, "~> 3.1", override: true}, # TODO: Update when Phoenix 1.3 will be released
     {:httpoison, "~> 0.10"},
     {:credit_card, "~> 1.0"},
     {:timex, "~> 3.0"},
     {:corsica, "~> 0.5"},
     {:excoveralls, "~> 0.5", only: [:dev, :test]},
     {:dogma, "> 0.1.0", only: [:dev, :test]},
     {:credo, ">= 0.4.12", only: [:dev, :test]}]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
     "test":       ["ecto.create --quiet", "ecto.migrate", "test"]]
  end
end
