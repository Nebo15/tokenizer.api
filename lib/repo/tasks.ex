defmodule :repo_tasks do
  @moduledoc """
  Nice way to apply migrations inside a released application.

  Example:

      gateway_api/bin/gateway_api command repo_tasks migrate!
  """

  @priv_dir "priv"
  @repo Repo

  def migrate! do
    # Migrate
    migrations_dir = Path.join([@priv_dir, "repo", "migrations"])

    # Run migrations
    @repo
    |> start_repo
    |> Ecto.Migrator.run(migrations_dir, :up, all: true)

    System.halt(0)
    :init.stop()
  end

  def seed! do
    seed_script = Path.join([@priv_dir, "repo", "seeds.exs"])

    # Run seed script
    start_repo(@repo)

    Code.require_file(seed_script)

    System.halt(0)
    :init.stop()
  end

  defp start_repo(repo) do
    load_app()
    repo.start_link()
    repo
  end

  defp load_app do
    start_applications([:logger, :postgrex, :ecto])
    :ok = Application.load(:gateway_api)
  end

  defp start_applications(apps) do
    Enum.each(apps, fn app ->
      {_, _message} = Application.ensure_all_started(app)
    end)
  end
end
