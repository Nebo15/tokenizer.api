defmodule Tokenizer.Web do
  @moduledoc """
  A module defining __using__ hooks for controllers,
  views and so on.

  This can be used in your application as:

      use Tokenizer.Web, :controller
      use Tokenizer.Web, :view

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
      import EView.Changeset.CardNumberValidator
      import EView.Changeset.EmailValidator
      import EView.Changeset.PhoneNumberValidator
      import EView.Changeset.MetadataValidator
    end
  end

  def controller do
    quote do
      use Phoenix.Controller, namespace: Tokenizer

      alias Tokenizer.DB.Repo
      import Ecto
      import Ecto.Query

      import Tokenizer.Router.Helpers
    end
  end

  def view do
    quote do
      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_csrf_token: 0, get_flash: 2, view_module: 1]

      import Tokenizer.Router.Helpers
      import Phoenix.View
    end
  end

  def router do
    quote do
      use Phoenix.Router
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
