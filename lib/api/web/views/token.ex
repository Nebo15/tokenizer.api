defmodule API.Views.Token do
  @moduledoc """
  View for Card controller.
  """

  use API.Web, :view

  def render("card.json", %{card: card}) do
    card
  end
end
