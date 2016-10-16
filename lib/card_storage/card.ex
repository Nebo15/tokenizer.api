defmodule Tokenizer.CardStorage.Card do
  @moduledoc """
  GenServer worker that is parsing bson file and writing content to DB and MQ.

  It will exit with `:normal` reason when parsing is completed, so supervisor won't restart it.
  """
  use GenServer

  def start_link(card_data, token) do
    GenServer.start_link(__MODULE__, card_data, name: token)
  end

  @doc false
  def init(card_data) do
    {:ok, card_data, Confex.get(:mbill, :token_expiration_time)}
  end

  @doc """
  Return encrypted card data and destroy GenServer that stores it.
  """
  def get_data(pid) do
    GenServer.call(pid, :get)
  end

  @doc """
  Whenever you received card data, GenServer will be terminated. So it's possible to read this data only once.
  """
  def handle_call(:get, _from, state) do
    Process.send_after(self(), :timeout, 100)
    {:reply, state, []}
  end

  @doc """
  This function destroys card data after a given timeout.
  """
  def handle_info(:timeout, _state) do
    {:stop, :normal, []}
  end
end
