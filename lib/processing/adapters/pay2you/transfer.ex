defmodule Processing.Adapters.Pay2You.Transfer do
  @moduledoc """
  This module implements card2card and card2phone tranfsers interfaces.
  """
  require Logger
  alias Processing.Adapters.Pay2You.Error
  alias Processing.Adapters.Pay2You.Request
  alias Repo.Schemas.Card
  alias Repo.Schemas.CardNumber

  @config Confex.get(:gateway_api, :pay2you)
  @card2card_upstream_uri "/Card2Card/CreateCard2CardOperation"
  @card2phone_upstream_uri "/Card2Phone/CreateCard2PhoneOperation"
  @timeout 60_000

  def send(%Card{number: sender_number, cvv: sender_cvv,
                 expiration_month: sender_exp_month, expiration_year: sender_exp_year},
           %CardNumber{number: recipient_number}, %Decimal{} = amount, %Decimal{} = fee, sender_phone) do
    %{
      cardFrom: %{
        cardNumber: sender_number,
        dateValid: get_card_expiration(sender_exp_month, sender_exp_year),
        cvv: sender_cvv
      },
      ammount: %{
        summa: to_cents(amount),
        commission: to_cents(fee),
        type: @config[:project][:name]
      },
      cardTo: recipient_number,
      socialNumber: sender_phone,
      version: @config[:upstream_version]
    }
    |> post_transfer(@card2card_upstream_uri)
    |> normalize_response()
  end

  def send(%Card{number: sender_number, cvv: sender_cvv,
                 expiration_month: sender_exp_month, expiration_year: sender_exp_year},
           recipient_phone, %Decimal{} = amount, %Decimal{} = fee, sender_phone) when is_binary(recipient_phone) do
    %{
      cardFrom: %{
        cardNumber: sender_number,
        dateValid: get_card_expiration(sender_exp_month, sender_exp_year),
        cvv: sender_cvv
      },
      ammount: %{
        summa: to_cents(amount),
        commission: to_cents(fee),
        type: @config[:project][:name]
      },
      socialTo: recipient_phone,
      socialNumber: sender_phone,
      version: @config[:upstream_version]
    }
    |> post_transfer(@card2phone_upstream_uri)
    |> normalize_response()
  end

  defp get_card_expiration(expiration_month, expiration_year) when is_number(expiration_month),
    do: expiration_month |> to_string() |> get_card_expiration(expiration_year)
  defp get_card_expiration(expiration_month, expiration_year) when is_number(expiration_year),
    do: expiration_month |> get_card_expiration(to_string(expiration_year))
  defp get_card_expiration(<<expiration_month::bytes-size(1)>>, expiration_year),
    do: get_card_expiration("0" <> expiration_month, expiration_year)
  defp get_card_expiration(<<expiration_month::bytes-size(2)>>, <<expiration_year::bytes-size(2)>>),
    do: expiration_month <> "/" <> expiration_year
  defp get_card_expiration(<<expiration_month::bytes-size(2)>>, <<_::bytes-size(2), expiration_year::bytes-size(2)>>),
    do: expiration_month <> "/" <> expiration_year

  defp to_cents(%Decimal{} = number) do
    number
    |> Decimal.mult(Decimal.new(100))
    |> Decimal.to_integer()
  end

  defp post_transfer(params, upstream_uri) do
    opts = [connect_timeout: @timeout, recv_timeout: @timeout, timeout: @timeout]
    case Request.post(upstream_uri, params, [], opts) do
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

  defp normalize_response({:ok, %{"mPayNumber" => id, "mErrCode" => status_code}}) do
    {:error, %{
      external_id: to_string(id),
      status: "declined",
      decline: %{
        code: status_code,
        reason: Error.get_error_group(status_code)
      }
    }}
  end

  defp normalize_response({:ok, %{"operationNumber" => id, "mErrCode" => status_code}}) do
    {:error, %{
      external_id: to_string(id),
      status: "declined",
      decline: %{
        code: status_code,
        reason: Error.get_error_group(status_code)
      }
    }}
  end

  defp normalize_response({:ok, %{"operationNumber" => id, "secur3d" => authentication}})
    when is_map(authentication) do
    {:ok, %{
      external_id: to_string(id),
      auth: normalize_authentication(authentication),
      status: "authentication"
    }}
  end

  defp normalize_response({:ok, %{"operationNumber" => id, "state" => %{"code" => status_code}}}) do
    {:error, %{
      external_id: to_string(id),
      status: "declined",
      decline: %{
        code: status_code,
        reason: Error.get_error_group(status_code)
      }
    }}
  end

  # Lookup code
  defp normalize_authentication(%{"md" => md, "paReq" => "lookup"}),
    do: %Repo.Schemas.AuthorizationLookupCode{md: md}

  # 3D Secure
  defp normalize_authentication(%{"acsUrl" => asc_url, "paReq" => pa_req, "termUrl" => terminal_url, "md" => md}),
    do: %Repo.Schemas.Authorization3DS{acs_url: asc_url, pa_req: pa_req, terminal_url: terminal_url, md: md}
end
