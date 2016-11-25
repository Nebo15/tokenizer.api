defmodule API.Plugs.Authorization do
  @moduledoc """
  This plug implements token based consumer authentication on top of HTTP Basic Auth.
  """
  alias Plug.Conn

  @auhtorization_type "Basic"
  def init([]), do: Confex.get_map(:gateway_api, :consumer_tokens)

  def call(%Plug.Conn{} = conn, consumer_tokens) do
    conn
    |> get_assigns()
    |> assert_consumer_token(consumer_tokens)
  end

  defp get_assigns(%Plug.Conn{assigns: %{transfer_token: transfer_token, consumer_token: consumer_token}} = conn),
    do: {conn, [consumer_token, transfer_token]}
  defp get_assigns(conn), do: {conn, :unathorized}

  defp render(conn, "401.json") do
    body = "401.json"
    |> EView.Views.Error.render(%{
      invalid: %{
        entry_type: "header",
        entry: "Authorization"
      }
    })
    |> Poison.encode_to_iodata!

    conn
    |> Conn.resp(401, body)
    |> Conn.halt
  end

  defp assert_consumer_token({conn, :unathorized}, _), do: render(conn, "401.json")
  defp assert_consumer_token({conn, [consumer_token, _transfer_token] = credentials}, consumer_tokens) do
    case Enum.find(consumer_tokens, &(&1 == consumer_token)) do
      nil ->
        render(conn, "401.json")
      _ ->
        conn
    end
  end
end
