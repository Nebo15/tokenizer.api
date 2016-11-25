defmodule API.Repo.Schemas.AuthorizationLookupCode do
  @moduledoc """
  Model for Lookup-Code authorization response.
  """
  use API.Web, :schema

  @primary_key false
  embedded_schema do
    field :type, API.Repo.Enums.AuthTypes, default: "lookup-code"
    field :md, :string
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:md])
    |> validate_required([:md])
  end
end
