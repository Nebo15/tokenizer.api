defmodule Tokenizer.CardStorage.Card do
  @moduledoc """
  GenServer worker that is parsing bson file and writing content to DB and MQ.

  It will exit with `:normal` reason when parsing is completed, so supervisor won't restart it.
  """
  use GenServer

  @doc """
  Store Card Data in a read-once process with pre-defined expiration time.
  """
  def start_link([card_data: card_data, expires_in: expires_in, name: name]) do
    GenServer.start_link(__MODULE__, [card_data: card_data, expires_in: expires_in], name: name)
  end

  @doc false
  def init([card_data: card_data, expires_in: expires_in]) do
    {:ok, card_data, expires_in}
  end

  @doc """
  Return encrypted card data and destroy GenServer that stores it. So it's possible to read this data only once.
  """
  def get_data(pid_or_name) do
    GenServer.call(pid_or_name, :get)
  end

  @doc """
  Return expiration date and time for a given Card Storage process.
  """
  def get_data_expiration(pid_or_name) do
    GenServer.call(pid_or_name, :get_expiration)
  end

  @doc false
  def handle_call(:get, _from, card_data) do
    Process.send(self(), :timeout, [])
    {:reply, card_data, []}
  end

  @doc """
  This function destroys card data after a given expiration timeout `expires_in`.
  """
  def handle_info(:timeout, _state) do
    {:stop, :normal, []}
  end
end
