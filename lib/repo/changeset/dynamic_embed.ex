defmodule Repo.Changeset.DynamicEmbeds do
  @moduledoc """
  This module provides validation function that can inject `DynamicEmbed` type as embed schema in changeset.

  Also it will run embed run child changeset as `cast_embed` would do.
  """
  def cast_dynamic_embeds(changeset, fields, opts \\ []) do
    Enum.reduce(fields, changeset, fn field, changeset ->
      cast_dynamic_embed(changeset, field, opts)
    end)
  end

  def cast_dynamic_embed(%{params: params} = changeset, field, opts \\ []) do
    val = Map.get(params, to_string(field), nil) || Map.get(params, field, nil) # Map can be string- or atom-keyed
    case val do
      nil ->
        changeset
      change ->
        changeset
        |> resolve_embed_schema(field, change, opts)
    end
  end

  # Resolved embed type via types `resolve/1` method.
  defp resolve_embed_schema(%{types: types} = changeset, field, change, opts) when is_map(change) do
    key = cast_key!(field)
    type = Map.get(types, key)
    case type.resolve(change) do
      {:ok, schema} ->
        run_embed_validator(changeset, field, change, schema)
      {:error, _reason} ->
        put_invalid_type_error(changeset, key, type.types(), opts)
    end
  end

  defp resolve_embed_schema(%{types: types} = changeset, field, _change, opts) do
    key = cast_key!(field)
    type = Map.get(types, key)
    put_invalid_error(changeset, key, type, opts)
  end

  defp run_embed_validator(%{changes: changes, types: types, data: data} = changeset, field, change, schema) do
    on_cast = &schema.changeset(&1, &2)

    embed_changeset = schema
    |> build_embed_schema(field, changeset)
    |> schema.changeset(change)

    embed_type = data
    |> Map.get(:__struct__)
    |> build_embed_type(schema, field, on_cast)

    %{changeset | changes: Map.put(changes, field, embed_changeset),
                  valid?: changeset.valid? and embed_changeset.valid?,
                  types: Map.put(types, field, embed_type)}
  end

  defp build_embed_type(owner, schema, field, on_cast) do
    {:embed, %Ecto.Embedded{
        cardinality: :one, field: field,
        on_cast: on_cast,
        on_replace: :raise, owner: owner,
        related: schema, unique: true
      }
    }
  end

  defp build_embed_schema(schema, field, %{data: data}) when is_map(data) and not is_nil(data) do
    data = Map.get(data, field) || %{} # This || is valid because there are always nil value when there is no data
    schema
    |> struct(data)
  end

  defp build_embed_schema(schema, _field, _parent_changeset) do
    schema
    |> struct(%{})
  end

  defp cast_key!(key) when is_atom(key), do: key
  defp cast_key!(key) when is_binary(key) do
    try do
      String.to_existing_atom(key)
    rescue
      ArgumentError ->
        raise ArgumentError, "could not convert the parameter `#{key}` into an atom, `#{key}` is not a schema field"
    end
  end

  defp put_invalid_type_error(%{errors: errors} = changeset, key, types, opts) do
    %{changeset |
      errors: [{key, {message(opts, :message, "have unknown type"),
               [inclusion: types, validation: :inclusion]}} | errors],
      valid?: false
    }
  end

  defp put_invalid_error(%{errors: errors} = changeset, key, _type, opts) do
    %{changeset |
      errors: [{key, {message(opts, :message, "is invalid"), [type: :map, validation: :cast]}} | errors],
      valid?: false
    }
  end

  defp message(opts, key, default) do
    Keyword.get(opts, key, default)
  end
end
