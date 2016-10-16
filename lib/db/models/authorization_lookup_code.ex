defmodule Tokenizer.DB.Models.AuthorizationLookupCode do
  use Tokenizer.Web, :model

  @primary_key false
  embedded_schema do
    field :type, :string, default: "lookup_code"
    field :md, :string
  end
end
