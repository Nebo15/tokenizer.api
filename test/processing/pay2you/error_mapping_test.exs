defmodule Processing.Pay2YouErrorMappingTest do
  use ExUnit.Case, async: true

  alias Repo.Schemas.Authorization3DS
  alias Repo.Schemas.AuthorizationLookupCode
  alias Processing.Adapters.Pay2You.Status

  @transaction_id_error "59390cad-a7e3-4170-a0bd-5546f731b500"
  @transaction_id_secure "cc0f4625-c406-4678-a1ee-37e3183b4a91"
  @transaction_id_lookup "cc0f4625-c406-4678-a1ee-37e3183b4900"
  @transaction_id_created "59390cad-a7e3-4170-a0bd-5546f731b201"
  @transaction_id_processing_error "59390cad-a7e3-4170-a0bd-2ee4cc3ddad1"

  describe "status" do
    defmodule P2Y do
      use MicroservicesHelper

      Plug.Router.get "/transfer/status" do

        data = case conn.params do
          %{"transactionId" => "59390cad-a7e3-4170-a0bd-5546f731b201"} -> %{
            "status" => "CREATED",
            "transactionId" => "59390cad-a7e3-4170-a0bd-5546f731b201",
          }

          %{"transactionId" => "cc0f4625-c406-4678-a1ee-37e3183b4a91"} -> %{
              "amount" => 100,
              "fundingProcessing" => "TAS",
              "paymentProcessing" => "TAS",
              "secureParams" => %{
                "MD" => "cc0f4625-c406-4678-a1ee-37e3183b4a91",
                "acsUrl" => "https://acs.privatbank.ua/pPaReqMC.jsp",
                "paReq" => "eJxVUk1v2zAMPedfFL3P+vCHnIAVkC9idG/+3VPz8Et7c=",
                "termUrl" => "https://api.p2y.com.ua/transfer/term"
              },
              "status" => "SECURE",
              "transactionId" => "cc0f4625-c406-4678-a1ee-37e3183b4a91",
            }

          %{"transactionId" => "cc0f4625-c406-4678-a1ee-2ee4cc3ddad1"} -> %{
              "transactionId": "cc0f4625-c406-4678-a1ee-2ee4cc3ddad1",
              "status": "PROCESSING_ERROR",
              "message": "Unknown error",
              "amount": 100,
              "fee": 500,
              "fundingProcessing": "TAS",
              "paymentProcessing": "TAS",
              "fundingProcessingCode": "811",
              "fundingProcessingMessage": "System error",
              "resultCode": "811",
              "resultMessage": "System error",
            }

          %{"transactionId" => "cc0f4625-c406-4678-a1ee-37e3183b4900"} -> %{
              "status" => "LOOKUP",
              "transactionId" => "cc0f4625-c406-4678-a1ee-37e3183b4900",
            }

          _ -> %{
            "status" => "ERROR",
            "fundingProcessingCode" => "811",
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
      assert {:ok, %{status: "declined", decline: %{
               code: "811",
               reason: "Internal_Error__Aquier"
             }}} = Status.recursive_get(@transaction_id_error)
    end

    test "map PROCESSING_ERROR" do
      assert {:ok, %{status: "declined", decline: %{
               code: "811",
               reason: "Internal_Error__Aqui2er"
             }}} = Status.recursive_get(@transaction_id_processing_error)
    end

    test "map SECURE" do
      assert {:ok, %{
               status: "authentication",
               auth: %Authorization3DS{md: @transaction_id_secure}
             }} = Status.recursive_get(@transaction_id_secure)
    end

    test "map LOOKUP" do
      assert {:ok, %{
               status: "authentication",
               auth: %AuthorizationLookupCode{md: @transaction_id_lookup}
             }} = Status.recursive_get(@transaction_id_lookup)
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


