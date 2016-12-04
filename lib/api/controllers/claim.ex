defmodule API.Controllers.Claim do
  @moduledoc """
  This controller implements REST API to claim right to receive claim by token.
  """
  use API.Web, :controller
  import Ecto.Query, only: [from: 2]
  alias API.Repo.Schemas.Claim, as: ClaimSchema
  alias API.Repo.Schemas.Transfer, as: TransferSchema
  alias API.Views.Claim, as: ClaimView
  alias API.Repo
  alias Ecto.Changeset

  @claim_token_prefix "claim-token"

  @doc """
  POST /claims
  """
  def create(conn, params) when is_map(params) do
    %ClaimSchema{}
    |> ClaimSchema.changeset(params)
    |> validate_id()
    |> put_claim_token()
    |> create_claim()
    |> render_response(conn, :created)
  end

  defp validate_id(changeset) do
    case Changeset.fetch_field(changeset, :id) do
      {_, id} ->
        do_validate_id(changeset, id)
      :error ->
        changeset
    end
  end

  defp do_validate_id(changeset, claim_id) do
    result = Repo.one from t in TransferSchema,
      where: fragment("(?)->'credential'->>'id' = ?", t.recipient, ^claim_id) and
             t.status in ["processing", "completed"]

    case result do
      nil ->
        changeset
        |> Changeset.add_error(:id, "not found", validation: :claim_id)
      %TransferSchema{id: transfer_id} ->
        changeset
        |> Changeset.put_change(:transfer_id, transfer_id)
    end
  end

  defp put_claim_token(%Changeset{valid?: false} = changeset), do: changeset
  defp put_claim_token(%Changeset{valid?: true} = changeset) do
    expires_in = Confex.get(:gateway_api, :claim_token_expires_in)

    expires_at = Timex.now
    |> Timex.shift(microseconds: expires_in)

    changeset
    |> Changeset.put_change(:token, @claim_token_prefix <> "-" <> Ecto.UUID.generate)
    |> Changeset.put_change(:token_expires_at, expires_at)
  end

  # Store claim changes into DB
  defp create_claim(%Changeset{valid?: false} = changeset), do: {:error, changeset}
  defp create_claim(%Changeset{valid?: true} = changeset) do
    changeset
    |> ClaimSchema.insert
  end

  @doc """
  GET /claims/:id
  """
  def show(conn, %{"id" => id}) do
    ClaimSchema
    |> Repo.get_by(id: id)
    |> Repo.preload(:transfer)
    |> validate_query_result()
    |> validate_token(conn)
    |> update_claim_status()
    |> update_claim()
    |> render_response(conn)
  end

  @doc """
  POST /claims/:id/auth
  """
  def authentificate(conn, %{"id" => id} = params) do
    ClaimSchema
    |> Repo.get_by(id: id)
    |> Repo.preload(:transfer)
    |> validate_query_result()
    |> validate_token(conn)
    |> validate_otp_code(params)
    |> update_claim()
    |> render_response(conn)
  end

  defp validate_query_result(nil), do: {:error, :not_found}
  defp validate_query_result(%ClaimSchema{} = claim), do: {:ok, claim}

  defp validate_otp_code({:error, reason}, _params), do: {:error, reason}
  defp validate_otp_code({:ok, %{id: external_id, credential: recipient_credential,
    transfer: %{recipient: %{phone: recipient_phone}}} = claim}, %{"code" => otp_code}) do
    case Processing.Adapters.Pay2You.Receive.receive(external_id, recipient_credential, recipient_phone, otp_code) do
      {:ok, update} ->
        changeset = claim
        |> Changeset.change(update)

        {:ok, changeset}
      {:error, :invalid_otp_code} ->
        changeset = claim
        |> Changeset.change()
        |> Changeset.add_error(:code, "is invalid", validation: :otp_code)

        {:error, changeset}
      {:error, %{status: _} = error_update} ->
        changeset = claim
        |> Changeset.change(error_update)

        {:ok, changeset}
    end
  end
  defp validate_otp_code({:ok, claim}, _params) do
    changeset = claim
    |> Changeset.change()
    |> Changeset.add_error(:code, "is required", validation: :required)

    {:error, changeset}
  end

  defp update_claim_status({:error, reason}), do: {:error, reason}
  defp update_claim_status({:ok, %ClaimSchema{transfer: %{external_id: external_id} = transfer} = claim}) do
    {_, update} = Processing.Adapters.Pay2You.Status.get(external_id)

    transfer
    |> Changeset.change(update)
    |> TransferSchema.update()

    claim_update = if claim.status == "processing", do: update |> Map.take([:status]), else: %{}

    claim = claim
    |> Changeset.change(claim_update)

    {:ok, claim}
  end

  defp update_claim({:error, reason}), do: {:error, reason}
  defp update_claim({:ok, changeset}) do
    changeset
    |> ClaimSchema.update
  end

  defp validate_token({:error, reason}, _conn), do: {:error, reason}
  defp validate_token({:ok, %{token: claim_token} = claim}, %Plug.Conn{assigns: %{token: user_token}})
    when claim_token == user_token,
    do: {:ok, claim}
  defp validate_token({:ok, _claim}, _conn), do: {:error, :access_denied}

  # Responses
  defp render_response(state, conn, status \\ :ok)

  defp render_response({:ok, %ClaimSchema{} = claim}, conn, status) do
    conn
    |> put_status(status)
    |> render(ClaimView, "claim.json", claim: claim)
  end

  defp render_response({:error, %Changeset{valid?: false} = changeset}, conn, _status) do
    conn
    |> put_status(422)
    |> render(EView.Views.ValidationError, "422.json", changeset)
  end

  defp render_response({:error, :not_found}, conn, _status) do
    conn
    |> put_status(404)
    |> render(EView.Views.Error, "404.json", %{})
  end

  defp render_response({:error, :access_denied}, conn, _status) do
    conn
    |> put_status(401)
    |> render(EView.Views.Error, "401.json", %{})
  end
end
