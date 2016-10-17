defmodule Tokenizer.DB.Types.Authorization do
  @behaviour Ecto.Type

  # Return type name
  def type, do: Tokenizer.DB.Types.Authorization

  # Cast type to the one that can be saved in DB
  def cast(%Tokenizer.DB.Models.Authorization3DS{} = auth) when is_map(auth) do
    IO.inspect auth
    {:ok, Map.delete(auth, :__struct__)}
  end

  def cast(%Tokenizer.DB.Models.AuthorizationLookupCode{} = auth) when is_map(auth) do
    {:ok, Map.delete(auth, :__struct__)}
  end

  def cast(nil), do: {:ok, nil}
  def cast(_), do: :error

  # When loading data from the database, we are guaranteed to
  # receive an integer (as databases are strict) and we will
  # just return it to be stored in the schema struct.
  def load(integer) when is_integer(integer), do: {:ok, integer}

  def load(%{type: "3d_secure"} = params) do
    {:ok, struct(Tokenizer.DB.Models.Authorization3DS, params)}
  end

  def load(%{type: "lookup_code"} = params) do
    {:ok, struct(Tokenizer.DB.Models.AuthorizationLookupCode, params)}
  end

  def load(_), do: {:error, :unkown_map_type}

  # When dumping data to the database, we *expect* an integer
  # but any value could be inserted into the struct, so we need
  # guard against them.
  def dump(map) when is_map(map), do: {:ok, map}
  def dump(_), do: :error
end
