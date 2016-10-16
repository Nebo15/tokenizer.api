defmodule Tokenizer.CardStorage.Encryptor do
  @moduledoc """
  This module implement AES cbc-128 encryption with HMAC signature for binary resources.
  """

  @doc """
  Encrypt message `message` with `key`.
  You can pass a list of `keys` when you want to run encryption multiple times.
  """
  def encrypt(message, keys) when is_binary(message) and is_list(keys) do
    keys
    |> Enum.reduce(message, fn key, acc ->
      acc
      |> encrypt(key)
    end)
  end

  def encrypt(message, key) when is_binary(message) do
    iv     = :crypto.strong_rand_bytes(16) # Random IVs for each encryption
    key    = trim_key(key)
    data   = {message, :os.timestamp()}
    |> :erlang.term_to_binary
    |> pad_16

    # Encrypt and sign data
    cipher    = :crypto.block_encrypt(:aes_cbc128, key, iv, data)
    signature = :crypto.hmac(:sha256, key, cipher <> iv)

    iv <> signature <> cipher
  end

  @doc """
  Decrypt result of `encrypt/2` with `key`.
  You can pass a list of `keys` when you want to run decryption multiple times.

  It returns:
  - `message` - decrypted message.
  - `{:error, :invalid_key_or_signature}` - when key or signature is invalid.
  - `{:error, :invalid_data}` - when data can not be recognized as encoded message.
  """
  def decrypt({:error, reason}, _), do: {:error, reason}

  def decrypt(message, keys) when is_binary(message) and is_list(keys) do
    keys
    |> Enum.reduce(message, fn key, acc ->
      acc
      |> decrypt(key)
    end)
  end

  def decrypt(<<iv::binary-16, signature::binary-32, cipher::binary>>, key) when is_binary(key) do
    key = trim_key(key)

    case :crypto.hmac(:sha256, key, cipher <> iv) do
      ^signature ->
        decrypt_block(key, iv, cipher)
      _ ->
        {:error, :invalid_key_or_signature}
    end
  end

  def decrypt(data, key) when is_binary(data) and is_binary(key) do
    {:error, :invalid_data}
  end

  defp decrypt_block(key, iv, cipher) do
    try do
      {message, _time} = :aes_cbc128
      |> :crypto.block_decrypt(key, iv, cipher)
      |> :erlang.binary_to_term([:safe])

      message
    rescue
      _ in ArgumentError -> {:error, :invalid_key_or_signature}
    end
  end

  defp trim_key(key) when byte_size(key) < 16 do
    key
    |> pad_16
    |> trim_key
  end

  defp trim_key(<<key::binary-16, _::binary>>)do
    key
  end

  defp pad_16(key) when rem(byte_size(key), 16) == 0 do
    key
  end

  defp pad_16(key) when is_binary(key) do
    padding = key
    |> Kernel.byte_size
    |> rem(16)

    key <> String.duplicate("0", 16 - padding)
  end
end
