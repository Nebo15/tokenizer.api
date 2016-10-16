defmodule EView.AcceptanceCase do
  @moduledoc """
  This module defines the test case to be used by
  acceptance tests. It can allow run tests in async when each SQL.Sandbox connection will be
  binded to a specific test.
  """

  use ExUnit.CaseTemplate

  using(opts) do
    quote location: :keep, bind_quoted: [opts: opts] do
      unless opts[:otp_app] do
        throw "You need to specify `otp_app` when using AcceptanceCase."
      end

      unless opts[:endpoint] do
        throw "You need to specify `endpoint` when using AcceptanceCase."
      end

      # Configure acceptance testing on different host:port
      conf = Application.get_env(opts[:otp_app], opts[:endpoint])
      host = conf[:http][:host] || "localhost"
      port = conf[:http][:port]

      @http_uri "http://#{host}:#{port}/"
      @repo opts[:repo]
      @async opts[:async]
      @endpoint opts[:endpoint]
      @headers opts[:headers] || []

      use HTTPoison.Base
      import Ecto.Query, only: [from: 2]
      import EView.AcceptanceCase
      # if opts[:repo] do
      #   alias @repo
      # end

      def process_url(url) do
        @http_uri <> url
      end

      defp process_request_headers(headers) do
        beam_headers = #if @repo and @async do
        #   meta = Phoenix.Ecto.SQL.Sandbox.metadata_for(@repo, self())

        #   encoded = {:v1, meta}
        #   |> :erlang.term_to_binary
        #   |> Base.url_encode64

        #   [{"User-Agent", "BeamMetadata (#{encoded})"}]
        # else
          []
        # end

        [{"content-type", "application/json"}] ++ beam_headers ++ @headers ++ headers
      end

      defp process_request_body(body) do
        body
        |> Poison.encode!
      end

      defp process_response_body(body) do
        body
        |> Poison.decode!
      end

      if opts[:repo] do
        setup tags do
          :ok = Ecto.Adapters.SQL.Sandbox.checkout(@repo)

          unless tags[:async] do
             Ecto.Adapters.SQL.Sandbox.mode(@repo, {:shared, self()})
          end
          :ok
        end
      end
    end
  end

  def get_body(map) do
    map
    |> Map.get(:body)
  end
end
