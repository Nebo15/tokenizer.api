defmodule API.Views.Claim do
  @moduledoc """
  View for Card controller.
  """
  use API.Web, :view

  def render("claim.json", %{claim: %{status: status} = claim})
    when status in ["authentication", "processing", "declined", "error"] do
    claim
    |> render_claim()
  end

  def render("claim.json", %{claim: %{status: status, transfer: transfer} = claim})
    when status in ["completed"] do
    claim
    |> render_claim()
    |> Map.put(:payment, %{
      id: transfer.id,
      status: transfer.status,
      amount: transfer.amount,
      fee: transfer.fee,
      total: Decimal.add(transfer.amount, transfer.fee),
      description: transfer.description,
      sender: render_one(transfer.sender, API.Views.Transfer, "peer.json", as: :peer),
      recipient: render_one(transfer.recipient, API.Views.Transfer, "peer.json", as: :peer),
      created_at: transfer.inserted_at,
      updated_at: transfer.updated_at
    })
  end

  defp render_claim(claim) do
    %{id: claim.id,
      external_id: claim.external_id,
      status: claim.status,
      token: claim.token,
      token_expires_at: claim.token_expires_at,
      credential: render_one(claim.credential, API.Views.Credential, "credential.json", as: :credential),
      auth: claim.auth,
      metadata: claim.metadata,
      created_at: claim.inserted_at,
      updated_at: claim.updated_at}
  end
end
