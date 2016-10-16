defmodule Tokenizer.CardStorage.EncryptorTest do
  use ExUnit.Case, async: true
  alias Tokenizer.CardStorage.Encryptor

  @sample_data "sample_data"
  @valid_key "0123456789ABCDEF"
  @long_key "0123456789ABCDEFA"
  @short_key "0"

  test "encrypts and decrypts strings with 16-byte key" do
    assert @sample_data == @sample_data
    |> Encryptor.encrypt(@valid_key)
    |> Encryptor.decrypt(@valid_key)
  end

  test "encrypts and decrypts strings with not 16-byte key" do
    assert @sample_data == @sample_data
    |> Encryptor.encrypt(@long_key)
    |> Encryptor.decrypt(@long_key)
  end

  test "encrypts and decrypts strings with short key" do
    assert @sample_data == @sample_data
    |> Encryptor.encrypt(@short_key)
    |> Encryptor.decrypt(@short_key)
  end

  test "returns error when signature is invalid" do
    enc = @sample_data
    |> Encryptor.encrypt(@valid_key)

    assert {:error, :invalid_key_or_signature} = Encryptor.decrypt("0" <> enc, @valid_key)
  end

  test "returns error when key is invalid" do
    enc = @sample_data
    |> Encryptor.encrypt(@valid_key)

    assert {:error, :invalid_key_or_signature} = Encryptor.decrypt(enc, @short_key)
  end

  test "returns error when decryption trash" do
    assert {:error, :invalid_data} = Encryptor.decrypt("abcde", @short_key)
  end

  test "encrypts and decrypts strings with multiple keys" do
    assert @sample_data == @sample_data
    |> Encryptor.encrypt([@valid_key, @long_key])
    |> Encryptor.decrypt([@valid_key, @long_key])
  end
end
