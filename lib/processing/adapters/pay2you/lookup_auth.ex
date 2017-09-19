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
      transactiontId: md,
      code: code
    }
    |> post_auth()
    |> normalize_response()
  end

  defp post_auth(params) do
    opts = [connect_timeout: @timeout, recv_timeout: @timeout, timeout: @timeout]
    case Request.post(@auth_upstream_uri, params, [], opts) do
      {:ok, %{body: body}} -> {:ok, body}
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
