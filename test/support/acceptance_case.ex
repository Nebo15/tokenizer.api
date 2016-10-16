defmodule Tokenizer.AcceptanceCase do
  @moduledoc """
  This module defines the test case to be used by
  acceptance tests. It can allow run tests in async when each SQL.Sandbox connection will be
  binded to a specific test.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      import Ecto
      import Ecto.Query, only: [from: 2]
      import Tokenizer.Router.Helpers

      alias Tokenizer.Repo

      use HTTPoison.Base

      @endpoint Tokenizer.Endpoint

      # Configure acceptance testing on different host:port
      conf = Application.get_env(:tokenizer_api, Tokenizer.Endpoint)
      host = System.get_env("MIX_TEST_HOST") || conf[:http][:host] || "localhost"
      port = System.get_env("MIX_TEST_PORT") || conf[:http][:port] || 4000

      @http_uri "http://#{host}:#{port}/"

      def process_url(url) do
        @http_uri <> url
      end

      @metadata_prefix "BeamMetadata"
      defp process_request_headers(headers) do
        meta = Phoenix.Ecto.SQL.Sandbox.metadata_for(Tokenizer.Repo, self())
        encoded = {:v1, meta}
        |> :erlang.term_to_binary
        |> Base.url_encode64

        headers ++ [{"User-Agent", "#{@metadata_prefix} (#{encoded})"}]
      end
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Tokenizer.Repo)

    unless tags[:async] do
       Ecto.Adapters.SQL.Sandbox.mode(Tokenizer.Repo, {:shared, self()})
    end
    :ok
  end
end
