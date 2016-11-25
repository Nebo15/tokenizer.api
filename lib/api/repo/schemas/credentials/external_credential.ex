defmodule API.Repo.Schemas.ExternalCredential do
  @moduledoc """
  Model for sender cards.
  """
  use API.Web, :schema

  @primary_key false
  embedded_schema do
    field :type, API.Repo.Enums.AccountCredential, default: "external-credential"
    field :id, :string
    field :metadata, :map
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:id, :metadata])
    |> validate_required([:id])
    |> validate_metadata(:metadata)
  end
end
