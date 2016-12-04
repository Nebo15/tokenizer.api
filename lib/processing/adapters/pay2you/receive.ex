defmodule Processing.Adapters.Pay2You.Receive do
  @moduledoc """
  This module implements lookup authorization for P2Y transfers.
  """
  require Logger
  alias Processing.Adapters.Pay2You.Error
  alias Processing.Adapters.Pay2You.Request
  alias API.Repo.Schemas.CardNumber

  @config Confex.get(:gateway_api, :pay2you)
  @claim_upstream_uri "/Phone2Card/CreatePhone2CardOperation?otpcode="

  def receive(external_id, %CardNumber{number: recipient_number}, recipient_phone, otp_code) do
    %{
      cardTo: recipient_number,
      socialNumber: recipient_phone,
      operationNumber: external_id
    }
    |> post_receive(otp_code)
    |> normalize_response()
  end

  defp post_receive(params, otp_code) do
    case Request.post(@claim_upstream_uri <> to_string(otp_code), params) do
      {:ok, %{body: body}} -> {:ok, body}
      {:error, reason} -> {:error, reason}
    end
  end

  defp normalize_response({:error, reason}) do
    Logger.warn("Transfer receive failed with error: #{inspect reason}")
    {:error, %{
      status: "error"
    }}
  end

  defp normalize_response({:ok, %{"state" => %{"code" => 19}}}),
    do: {:error, :invalid_otp_code}

  defp normalize_response({:ok, %{"state" => %{"code" => 0}}}),
    do: {:ok, %{status: "processing"}}

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
