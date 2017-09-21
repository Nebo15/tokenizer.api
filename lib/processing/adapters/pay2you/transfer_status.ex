defmodule Processing.Adapters.Pay2You.Status do
  @moduledoc """
  This module implements lookup authorization for P2Y transfers.
  """
  require Logger
  alias Processing.Adapters.Pay2You.Error
  alias Processing.Adapters.Pay2You.Request

  @status_upstream_uri "/transfer/status"
  @timeout 60_000

  def recursive_get(id, attempt \\ 1) do
    id
    |> get()
    |> check_transfer_status(attempt)
    |> case do
         :repeat -> recursive_get(id, attempt + 1)
         res -> res
       end
  end

  defp check_transfer_status({:ok, %{status: "processing"}}, attempt) when attempt <= 5 do
    :timer.sleep(1_000)
    :repeat
  end
  defp check_transfer_status(res, _attempt) do
    res
  end

  def get(id) do
    id
    |> get_status()
    |> normalize_response()
  end

  defp get_status(transactionId) do
    Logger.debug("Receiving new payment status, transactionId: #{transactionId}")
    opts = [connect_timeout: @timeout, recv_timeout: @timeout, timeout: @timeout]
    case Request.get(@status_upstream_uri <> "?transactionId=#{transactionId}", [], opts) do
      {:ok, %{body: body}} ->
        Logger.debug("Payment status for TransactionId #{transactionId}: #{inspect(body)}")
        {:ok, body}
      {:error, reason} -> {:error, reason}
    end
  end

  defp normalize_response({:error, reason}) do
    Logger.warn("Transfer failed with error: #{inspect reason}")
    {:error, %{status: "declined"}}
  end

  defp normalize_response({:ok, %{"status" => "PROCESSED"}}) do
    {:ok, %{status: "completed"}}
  end

  defp normalize_response({:ok, %{"status" => status, "transactionId" => transactionId} = resp})
       when status in ["SECURE", "LOOKUP"] do
    {:ok, %{
      external_id: to_string(transactionId),
      auth: prepare_auth(resp),
      status: "authentication",
    }}
  end

  defp normalize_response({:ok, %{"status" => status}}) when status in ["CREATED", "PENDING", "PROCESSING"] do
    {:ok, %{status: "processing"}}
  end

  defp normalize_response({:ok, %{"fundingProcessingCode" => status_code}}) do
    {:ok, %{
      status: "declined",
      decline: %{
        code: status_code,
        reason: Error.get_error_group(status_code)
      }
    }}
  end

  defp normalize_response(resp) do
    Logger.warn("Transfer response did not match any patterns: #{inspect resp}")
    {:error, %{status: "declined"}}
  end

  # Lookup code
  defp prepare_auth(%{"status" => "LOOKUP", "transactionId" => transaction_id}) do
    %Repo.Schemas.AuthorizationLookupCode{md: transaction_id}
  end

  # 3D Secure
  defp prepare_auth(%{"status" => "SECURE", "secureParams" => %{
    "acsUrl" => asc_url,
    "paReq" => pa_req,
    "termUrl" => terminal_url,
    "MD" => md}}) do

    %Repo.Schemas.Authorization3DS{acs_url: asc_url, pa_req: pa_req, terminal_url: terminal_url, md: md}
  end

  defp prepare_auth(data) do
    Logger.warn("normalize_authentication/2 Data not mapped: #{inspect data}")
    %{}
  end
end
