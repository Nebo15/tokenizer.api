defmodule Processing.Adapters.Pay2You.Receive do
  @moduledoc """
  This module implements lookup authorization for P2Y transfers.
  """
  require Logger
  alias Processing.Adapters.Pay2You.Error
  alias Processing.Adapters.Pay2You.Request
  alias API.Repo.Schemas.CardNumber

  @config Confex.get(:gateway_api, :pay2you)
  @claim_upstream_uri "/Phone2Card/CreatePhone2CardOperation"
  @timeout 60_000

  def receive(external_id, %CardNumber{number: recipient_number}, recipient_phone) do
    %{
      cardTo: recipient_number,
      socialNumber: recipient_phone,
      operationNumber: external_id
    }
    |> post_receive()
    |> normalize_response("authentication")
  end

  def auth(external_id, %CardNumber{number: recipient_number}, recipient_phone, otp_code) do
    %{
      cardTo: recipient_number,
      socialNumber: recipient_phone,
      operationNumber: external_id
    }
    |> post_auth(otp_code)
    |> normalize_response("processing")
  end

  defp post_receive(params) do
    opts = [connect_timeout: @timeout, recv_timeout: @timeout, timeout: @timeout]
    case Request.post(@claim_upstream_uri, params, [], opts) do
      {:ok, %{body: body}} -> {:ok, body}
      {:error, reason} -> {:error, reason}
    end
  end

  defp post_auth(params, otp_code) do
    opts = [connect_timeout: @timeout, recv_timeout: @timeout, timeout: @timeout]
    case Request.post(@claim_upstream_uri <> "?otpcode=" <> to_string(otp_code), params, [], opts) do
      {:ok, %{body: body}} -> {:ok, body}
      {:error, reason} -> {:error, reason}
    end
  end

  defp normalize_response({:error, reason}, _next_status) do
    Logger.warn("Transfer receive failed with error: #{inspect reason}")
    {:error, %{
      status: "declined",
      decline: %{
        code: "1"
      }
    }}
  end

  defp normalize_response({:ok, %{"state" => %{"code" => 19}}}, _next_status),
    do: {:error, :invalid_otp_code}

  defp normalize_response({:ok, %{"state" => %{"code" => 16}}}, _next_status),
    do: {:error, :not_found}

  defp normalize_response({:ok, %{"state" => %{"code" => 0}}}, next_status),
    do: {:ok, %{status: next_status}}

  defp normalize_response({:ok, %{"idClient" => id, "state" => %{"code" => status_code}}}, _next_status) do
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
