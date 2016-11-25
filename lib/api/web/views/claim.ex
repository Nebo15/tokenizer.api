defmodule API.Views.Claim do
  @moduledoc """
  View for Card controller.
  """

  use API.Web, :view

  def render("claim.json", %{claim: claim}) do
    claim
  end
end
