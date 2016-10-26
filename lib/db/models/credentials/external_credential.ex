defmodule Tokenizer.DB.Models.ExternalCredential do
  @moduledoc """
  Model for sender cards.
  """
  use Tokenizer.Web, :model

  @primary_key false
  embedded_schema do
    field :type, Tokenizer.DB.Enums.AccountCredential, default: "external-credential"
    field :id, :string
    field :metadata, :map
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:id, :metadata])
    |> validate_required([:id])
  end
end
