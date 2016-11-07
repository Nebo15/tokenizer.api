defmodule Tokenizer.HTTP.Plugs.Authorization do
  @moduledoc """
  This plug implements token based consumer authentication on top of HTTP Basic Auth.
  """
  alias Plug.Conn

  @auhtorization_type "Basic"
  def init([]), do: Confex.get_map(:tokenizer_api, :consumer_tokens)

  def call(%Plug.Conn{} = conn, consumer_tokens) do
    conn
    |> get_auth_header()
    |> get_credentials()
    |> decode_credentials()
    |> assert_consumer_token(consumer_tokens)
    |> put_assigns()
  end

  defp get_auth_header(conn) do
    {conn, Conn.get_req_header(conn, "authorization")}
  end

  defp get_credentials({conn, []}), do: {conn, :unathorized}
  defp get_credentials({conn, nil}), do: {conn, :unathorized}
  defp get_credentials({conn, [@auhtorization_type <> " " <> encoded_credentials | _]}) do
    case Base.decode64(encoded_credentials) do
      {:ok, credentials} ->
        {conn, credentials}
      {:error, _} ->
        {conn, :unathorized}
    end
  end
  defp get_credentials({conn, _}), do: {conn, :unathorized}

  defp decode_credentials({conn, :error}), do: {conn, :unathorized}
  defp decode_credentials({conn, :unathorized}), do: {conn, :unathorized}
  defp decode_credentials({conn, credentials}) do
    {conn, destructure([_consumer_token, _transfer_token], String.split(credentials, ":"))}
  end

  defp assert_consumer_token({conn, :unathorized}, _), do: {render(conn, "401.json"), :unathorized}
  defp assert_consumer_token({conn, [consumer_token, _transfer_token] = credentials}, consumer_tokens) do
    case Enum.find(consumer_tokens, &(&1 == consumer_token)) do
      nil ->
        {render(conn, "401.json"), :unathorized}
      _ ->
        {conn, credentials}
    end
  end

  defp put_assigns({conn, :unathorized}), do: conn
  defp put_assigns({conn, [consumer_token, transfer_token]}) do
    conn
    |> Conn.assign(:consumer_token, consumer_token)
    |> Conn.assign(:transfer_token, transfer_token)
  end

  defp render(conn, "401.json") do
    body = "401.json"
    |> EView.ErrorView.render(%{
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
end
