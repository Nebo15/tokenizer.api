defmodule Tokenizer.PageView do
  @moduledoc """
  Sample view for Pages controller.
  """

  use Tokenizer.Web, :view

  def render("page.json", _assigns) do
    %{page: %{detail: "This is page."}}
  end
end
