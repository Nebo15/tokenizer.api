defmodule Processing.Adapters.Pay2You.Request do
  @moduledoc """
  This is helper module that creates HTTP interface to request upstream back-end.
  """
  use HTTPoison.Base
  require Logger

  @transfer_uri "/Card2Card/CreateCard2CardOperation"

  def process_url(url) do
    upstream_url = Confex.get_map(:gateway_api, :pay2you)[:upstream_url]

    unless upstream_url do
      raise "Pay2You upstream URL is not set!"
    end
    Logger.debug("Request will be sent to: " <> upstream_url <> url)

    upstream_url <> url
  end

  defp process_request_headers(headers) do
    [{"content-type", "application/json"}] ++ headers
  end

  defp process_request_body(body) do
    body
    |> Poison.encode!
  end

  defp process_response_body(body) do
    case body |> Poison.decode do
      {:ok, resp} -> resp
      {:error, _} ->
        Logger.warn("Received corrupted body: #{inspect body}")
        {:error, :corrupted_body}
    end
  end
end
