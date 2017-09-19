defmodule Processing.Adapters.Pay2You.LookupAuth do
  @moduledoc """
  This module implements lookup authorization for P2Y transfers.
  """
  require Logger
  alias Processing.Adapters.Pay2You.Error
  alias Processing.Adapters.Pay2You.Request
  alias Repo.Schemas.AuthorizationLookupCode

  @auth_upstream_uri "/transfer/confirm/lookup"
  @timeout 60_000

  def auth(%AuthorizationLookupCode{md: md}, code) do
    %{
      transactionId: md,
      code: to_string(code)
    }
    |> post_auth()
    |> normalize_response()
  end

  defp post_auth(params) do
    opts = [connect_timeout: @timeout, recv_timeout: @timeout, timeout: @timeout]
    case Request.post(@auth_upstream_uri, params, [], opts) do
      {:ok, %{status_code: 200, body: body}} -> {:ok, body}
      {:ok, %{status_code: 400}} ->{:error, "400 Bad Request"}
      {:error, reason} -> {:error, reason}
    end
  end

  defp normalize_response({:error, reason}) do
    Logger.warn("Transfer failed with error: #{inspect reason}")
    {:error, %{
      status: "declined",
      decline: %{
        code: "1"
      }
    }}
  end

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

  defp normalize_response({:ok, ""}) do
    {:ok, %{status: "processing"}}
  end

  defp normalize_response({:ok, data}) do
    Logger.warn("LookupAuth.normalize_response/1 data not mapped: #{inspect data}")
    {:error, :invalid_otp_code}
  end
end
