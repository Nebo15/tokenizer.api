defmodule API.Helpers.TokenResolver do
  @moduledoc false
  alias Ecto.Changeset
  alias Tokenizer.Supervisor, as: Tokenizer

  @doc """
  Resolve card-token credentials to a card data. Returns: `Ecto.Changeset`.
  """
  def resolve_credentials(%Changeset{} = changeset, peer_type) when peer_type in [:sender, :recipient] do
    peer = changeset
    |> fetch_field(peer_type)

    credential = peer
    |> fetch_field(:credential)

    credential
    |> validate_type("card-token")
    |> fetch_field(:token, :invalid_token)
    |> resolve_token(changeset, credential, peer_type, peer)
  end

  defp fetch_field(data, _field, default \\ :error)
  defp fetch_field(:error, _field, _default), do: :error
  defp fetch_field(%Changeset{} = changeset, field, default) do
    case Changeset.fetch_change(changeset, field) do
      {_, value} -> value
      :error -> default
    end
  end
  defp fetch_field(%{} = schema, field, default) do
    Map.get(schema, field, default)
  end

  defp validate_type(:error, _field), do: :error
  defp validate_type(changeset, type) do
    case Changeset.fetch_field(changeset, :type) do
      {_, ^type} -> changeset
      _ -> :error
    end
  end

  defp resolve_token(:error, changeset, _credential, _peer_type, _peer),
    do: changeset
  defp resolve_token(:invalid_token, changeset, credential, peer_type, peer),
    do: credential |> put_token_error(peer_type, peer, changeset)
  defp resolve_token(token, changeset, credential, peer_type, peer) do
    case Tokenizer.get_card(token) do
      {:ok, card_data} ->
        card_data
        |> put_in_credential(peer_type, peer, changeset)
      {:error, _} ->
        credential
        |> put_token_error(peer_type, peer, changeset)
    end
  end

  defp put_in_credential(credential, peer_type, peer, changeset) do
    peer = peer
    |> Changeset.put_embed(:credential, credential)

    changeset
    |> Changeset.put_embed(peer_type, peer)
  end

  defp put_token_error(credential, peer_type, peer, changeset) do
    credential
    |> Changeset.add_error(:token, "is invalid", validation: :token)
    |> put_in_credential(peer_type, peer, changeset)
  end
end
