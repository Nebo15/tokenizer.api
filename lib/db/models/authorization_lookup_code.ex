defmodule Tokenizer.DB.Models.AuthorizationLookupCode do
  @moduledoc """
  Model for Lookup-Code authorization response.
  """
  use Tokenizer.Web, :model

  @primary_key false
  embedded_schema do
    field :type, :string, default: "lookup_code"
    field :md, :string
  end
end
