defmodule Tokenizer.Views.Payment do
  @moduledoc """
  View for Payment controller.
  """

  use Tokenizer.Web, :view

  def render("payment.json", _assigns) do
    %{page: %{detail: "This is page."}}
  end
end
