defmodule Processing.Adapters.Pay2You.Status do
  @moduledoc """
  This module implements lookup authorization for P2Y transfers.
  """
  require Logger
  alias Processing.Adapters.Pay2You.Error
  alias Processing.Adapters.Pay2You.Request

  @status_upstream_uri "/transfer/status"
  @timeout 60_000

  def get(id) do
    id
    |> get_status()
    |> normalize_response()
  end

  defp get_status(transactiontId) do
    Logger.debug("Receiving new payment status, transactionId: #{transactiontId}")
    opts = [connect_timeout: @timeout, recv_timeout: @timeout, timeout: @timeout]
    case Request.get(@status_upstream_uri <> "?transactionId=#{transactiontId}", [], opts) do
      {:ok, %{body: body}} -> {:ok, body}
      {:error, reason} -> {:error, reason}
    end
  end

  defp normalize_response({:error, reason}) do
    Logger.warn("Transfer failed with error: #{inspect reason}")
    {:error, %{status: "declined"}}
  end

  defp normalize_response({:ok, %{"mErrCode" => 0}}),
    do: {:ok, %{status: "completed"}}

  # 3DS or lookup code is not sent yet
  defp normalize_response({:ok, %{"mErrCode" => status_code}}) when status_code in [56, 49, 59],
    do: {:ok, %{status: "authentication"}}

  defp normalize_response({:ok, %{"mErrCode" => status_code}}) do
    {:ok, %{
      status: "declined",
      decline: %{
        code: status_code,
        reason: Error.get_error_group(status_code)
      }
    }}
  end

  defp normalize_response({:ok, %{"status" => "PROCESSED"}}) do
    {:ok, %{status: "completed"}}
  end

  defp normalize_response({:ok, %{"status" => "ABORTED"}}) do
    {:ok, %{status: "declined"}}
  end

  defp normalize_response({:ok, %{"status" => status}}) in ["PROCESSING_ERROR", "ERROR"] do
    {:error, %{status: "error"}}
  end

  defp normalize_response(resp) do
    Logger.warn("Transfer response did not match any patterns: #{inspect resp}")
#    {:error, %{status: "declined"}}
    resp
  end
end
