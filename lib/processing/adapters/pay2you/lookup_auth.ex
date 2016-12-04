defmodule Processing.Adapters.Pay2You.LookupAuth do
  @moduledoc """
  This module implements lookup authorization for P2Y transfers.
  """
  require Logger
  alias Processing.Adapters.Pay2You.Error
  alias Processing.Adapters.Pay2You.Request
  alias API.Repo.Schemas.AuthorizationLookupCode

  @config Confex.get(:gateway_api, :pay2you)
  @auth_upstream_uri "/ConfirmLookUp/finishlookup"

  def auth(%AuthorizationLookupCode{md: md}, code) do
    %{
      md: md,
      paRes: code,
      cvv: "000"
    }
    |> post_auth()
    |> normalize_response()
  end

  defp post_auth(params) do
    case Request.post(@auth_upstream_uri, params) do
      {:ok, %{body: body}} -> {:ok, body}
      {:error, reason} -> {:error, reason}
    end
  end

  defp normalize_response({:error, reason}) do
    Logger.warn("Transfer failed with error: #{inspect reason}")
    {:error, %{
      status: "error"
    }}
  end

  defp normalize_response({:ok, %{"state" => %{"code" => 0}}}),
    do: {:ok, %{status: "processing"}}

  defp normalize_response({:ok, %{"state" => %{"code" => status_code}}}) when status_code == 49 or status_code == 59,
    do: {:error, :invalid_otp_code}

  defp normalize_response({:ok, %{"state" => %{"code" => status_code}}}) when status_code == 55 or status_code == 56,
    do: {:error, :invalid_auth_type}

  defp normalize_response({:ok, %{"idClient" => id, "state" => %{"code" => status_code}}}) do
    {:error, %{
      external_id: to_string(id),
      status: "declined",
      decline: %{
        code: status_code,
        reason: Error.get_error_group(status_code)
      }
    }}
  end
end
