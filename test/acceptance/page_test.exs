defmodule Tokenizer.PageAcceptanceTest do
  use Tokenizer.AcceptanceCase, async: true

  test "GET /page" do
    %{body: body} = get!("page")

    assert body == ~S({"page":{"detail":"This is page."}})
  end
end
