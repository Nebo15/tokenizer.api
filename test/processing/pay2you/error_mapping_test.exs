defmodule Processing.Pay2YouErrorMappingTest do
  use ExUnit.Case, async: true

  alias Processing.Adapters.Pay2You.Status

  @transaction_id_created "59390cad-a7e3-4170-a0bd-5546f731b201"
  @transaction_id_error "59390cad-a7e3-4170-a0bd-5546f731b500"

  describe "status" do
    defmodule P2Y do
      use MicroservicesHelper

      Plug.Router.get "/transfer/status" do

        data = case conn.params do
          %{"transactionId" => "59390cad-a7e3-4170-a0bd-5546f731b201"} -> %{
            "status" => "CREATED",
            "transactionId" => "59390cad-a7e3-4170-a0bd-5546f731b201",
          }
          _ -> %{
            "status" => "ERROR",
            "transactionId" => "59390cad-a7e3-4170-a0bd-5546f731b500",
          }
        end

        Plug.Conn.send_resp(conn, 200, Poison.encode!(data))
      end
    end

    setup do
      {:ok, port, ref} = start_microservices(P2Y)

      System.put_env("PAY2YOU_UPSTREAM_URL", "http://localhost:#{port}")
      on_exit fn ->
        System.put_env("PAY2YOU_UPSTREAM_URL", "http://p2y-dev.mbill.co/pay2you-ext")
        stop_microservices(ref)
      end
      :ok
    end

    test "map CREATED" do
      start = :os.system_time(:seconds)
      assert {:ok, %{status: "processing"}} = Status.recursive_get(@transaction_id_created, 5)
      assert 1 <= :os.system_time(:seconds) - start
    end

    test "map ERROR" do
      start = :os.system_time(:seconds)
      assert {:ok, %{status: "processing"}} = Status.recursive_get(@transaction_id_created, 5)
      assert 1 <= :os.system_time(:seconds) - start
    end
  end

  def start_microservices(module) do
    {:ok, port} = :gen_tcp.listen(0, [])
    {:ok, port_string} = :inet.port(port)
    :erlang.port_close(port)
    ref = make_ref()
    {:ok, _pid} = Plug.Adapters.Cowboy.http module, [], port: port_string, ref: ref # TODO: only 1 worker here
    {:ok, port_string, ref}
  end

  def stop_microservices(ref) do
    Plug.Adapters.Cowboy.shutdown(ref)
  end
end


