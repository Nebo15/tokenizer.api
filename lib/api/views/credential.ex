defmodule API.Views.Credential do
  @moduledoc false
  use API.Web, :view

  def render("credential.json", %{credential: %{type: type, number: number}}) when type in ["card", "card-number"] do
    %{type: type,
      number: hide_card_number(number)}
  end

  def render("credential.json", %{credential: %{type: type, id: id, metadata: metadata}})
      when type in ["external-credential"] do
    %{type: type,
      id: id,
      metadata: metadata}
  end

  defp hide_card_number(card_number) do
    String.slice(card_number, 0..5) <> String.duplicate("*", 6) <> String.slice(card_number, -4..-1)
  end
end
