defmodule Tokenizer.DB.Models.Authorization3DS do
  @moduledoc """
  Model for 3D-Secure authorization response.
  """
  use Tokenizer.Web, :model

  @primary_key false
  embedded_schema do
    field :type, Tokenizer.DB.Enums.AuthTypes, default: "3d_secure"
    field :acs_url, :string
    field :pa_req, :string
    field :terminal_url, :string
    field :md, :string
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:acs_url, :pa_req, :terminal_url, :md])
    |> validate_required([:acs_url, :pa_req, :terminal_url, :md])
  end
end
