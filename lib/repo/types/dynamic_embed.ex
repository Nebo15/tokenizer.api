defmodule Repo.Types.DynamicEmbed do
  @moduledoc """
  This module provides common interface and helper function for types that can be embedded dynamically into schema.
  """
  defmacro __using__(_) do
    quote do
      @behaviour Ecto.Type

      @doc """
      Returns type name.
      """
      def type, do: :map

      @doc """
      Helps to resolve string-keyed maps.
      """
      def resolve(%{"type" => _} = map) do
        map
        |> to_atom_keys()
        |> resolve()
      end

      @doc """
      Cast type to the one that can be saved in DB.
      """
      def cast(%{"type" => _} = credential) do
        credential
        |> to_atom_keys()
        |> cast()
      end

      def cast(%{type: _} = credential) do
        case resolve(credential) do
          {:ok, _type} ->
            {:ok, struct_to_map(credential)}
          {:error, _reason} ->
            :error
        end
      end

      def cast(nil), do: {:ok, nil}
      def cast(_), do: :error

      defp struct_to_map(struct) when is_map(struct) do
        Map.delete(struct, :__struct__)
      end

      # When loading data from the database, we are guaranteed to
      # receive an raw map (as databases are strict) and we will
      # just return it to be stored in the schema struct.
      def load(params) do
        case resolve(params) do
          {:ok, embed_type} -> {:ok, struct(embed_type, to_atom_keys(params))}
          {:error, reason} -> {:error, reason}
        end
      end

      # When dumping data to the database, we *expect* a map
      # but any value could be inserted into the struct, so we need
      # guard against them.
      def dump(%{__struct__: _} = struct), do: struct |> struct_to_map() |> dump()
      def dump(map) when is_map(map), do: {:ok, map}
      def dump(_), do: :error

      defp to_atom_keys(string_key_map) do
        for {key, val} <- string_key_map, into: %{} do
          case is_atom(key) do
            true -> {key, val}
            false -> {String.to_atom(key), val}
          end
        end
      end
    end
  end
end
