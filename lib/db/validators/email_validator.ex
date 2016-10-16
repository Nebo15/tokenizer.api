defmodule Ecto.Changeset.EmailValidator do
  @moduledoc """
  This helper validates emails by complex regex pattern.
  """
  import Ecto.Changeset

  @email_regex ~S((?:[a-z0-9!#$%&'*+\/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+\/=?^_`{|}~-]+\)*|") <>
               ~S((?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f]\)*"\)) <>
               ~S(@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9]\)?\.\)+[a-z0-9](?:[a-z0-9-]*[a-z0-9]\)?) <>
               ~S(|\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?\)\.\){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?) <>
               ~S(|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]) <>
               ~S(|\\[\x01-\x09\x0b\x0c\x0e-\x7f]\)+\)\]\))

  def validate_email(changeset, field, opts \\ []) do
    case Ecto.Changeset.get_field(changeset, field) do
      nil ->
        changeset
      _ ->
        changeset
        |> validate_format(field, ~r//, opts)
    end
  end
end
