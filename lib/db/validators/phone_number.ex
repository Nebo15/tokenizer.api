defmodule Ecto.Changeset.PhoneNumberValidator do
  import Ecto.Changeset

  def validate_phone_number(changeset, field, opts \\ []) do
    case Ecto.Changeset.get_field(changeset, field) do
      nil ->
        changeset
      _ ->
        changeset
        |> validate_format(field, ~r/^\+[0-9]{9,16}$/, opts)
    end
  end
end
