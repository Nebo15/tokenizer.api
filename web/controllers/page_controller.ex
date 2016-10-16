defmodule Tokenizer.PageController do
  @moduledoc """
  Sample controller for generated application.
  """

  use Tokenizer.Web, :controller

  def index(conn, _params) do
    render conn, "page.json"
  end
end
