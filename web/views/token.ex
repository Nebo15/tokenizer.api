defmodule Tokenizer.Views.Token do
  @moduledoc """
  View for Card controller.
  """

  use Tokenizer.Web, :view

  def render("card.json", %{card: card}) do
    card
  end
end
