defmodule API.Repo.Schemas.ExternalCredential do
  @moduledoc """
  Schema for sender cards.
  """
  use API.Web, :schema

  @primary_key false
  embedded_schema do
    field :type, :string, default: "external-credential"
    field :id, :string
    field :metadata, :map
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:metadata])
    |> validate_metadata(:metadata)
  end
end
