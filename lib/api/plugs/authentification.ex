defmodule API.Plugs.Authentification do
  @moduledoc """
  This plug implements token based consumer authentication on top of HTTP Basic Auth.
  """
  alias Plug.Conn

  @auhtorization_type "Basic"
  def init([]), do: []

  def call(%Plug.Conn{} = conn, _opts) do
    conn
    |> get_auth_header()
    |> get_credentials()
    |> decode_credentials()
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

  defp decode_credentials({conn, :unathorized}), do: {conn, :unathorized}
  defp decode_credentials({conn, credentials}) do
    {conn, destructure([_consumer_token, _unused_password], String.split(credentials, ":"))}
  end

  defp put_assigns({conn, :unathorized}), do: conn
  defp put_assigns({conn, [token, _]}) do
    conn
    |> Conn.assign(:token, token)
  end
end
