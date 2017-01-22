defmodule API.Web do
  @moduledoc """
  A module defining __using__ hooks for controllers,
  views and so on.

  This can be used in your application as:

      use API.Web, :controller
      use API.Web, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below.
  """
  def schema do
    quote do
      use Ecto.Schema

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import EView.Changeset.Validators.CardNumber
      import EView.Changeset.Validators.Email
      import EView.Changeset.Validators.PhoneNumber
      import EView.Changeset.Validators.Metadata

      alias Repo
    end
  end

  def controller do
    quote do
      use Phoenix.Controller, namespace: Tokenizer

      import Ecto
      import Ecto.Query
      import API.Router.Helpers

      alias Repo
    end
  end

  def view do
    quote do
      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_csrf_token: 0, get_flash: 2, view_module: 1]

      import API.Router.Helpers
      import Phoenix.View
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
