defmodule API.Views.Transfer do
  @moduledoc """
  View for Transfer controller.
  """

  use API.Web, :view

  def render("transfer.json", %{transfer: transfer}) do
    %{
      id: transfer.id,
      external_id: transfer.external_id,
      token: transfer.token,
      token_expires_at: transfer.token_expires_at,
      amount: transfer.amount,
      fee: transfer.fee,
      total: Decimal.add(transfer.amount, transfer.fee),
      description: transfer.description,
      status: transfer.status,
      auth: transfer.auth,
      metadata: transfer.metadata,
      sender: render_one(transfer.sender, API.Views.Transfer, "peer.json", as: :peer),
      recipient: render_one(transfer.recipient, API.Views.Transfer, "peer.json", as: :peer),
      created_at: transfer.inserted_at,
      updated_at: transfer.updated_at
    }
  end

  def render("peer.json", %{peer: peer}) do
    %{
      phone: peer.phone,
      email: peer.email,
      credential: render_one(peer.credential, API.Views.Credential, "credential.json", as: :credential)
    }
  end
end
