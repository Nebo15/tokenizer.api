defmodule Tokenizer.DB.Models.RecipientCard do
  use Tokenizer.Web, :model

  embedded_schema do
    field :number, :string
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:number])
    |> validate_required([:number])
    |> validate_format(:number, ~r/^\d{16}$/, message: "Must contains only 16 digits")
  end
end
