defmodule BeeRpcTest do
  use ExUnit.Case
  doctest BeeRpc

  setup do
    # Start the BeeRpc application for integration tests
    {ok, _pid} = start_supervised(BeeRpc.Server.Sup)
    :ok
  end

  describe "gRPC Greeter service" do
    test "say_hello returns a greeting via RPC call" do
      # Arrange
      request = %Echo.EchoReq{name: "Alice"}

      # Act
      {:ok, channel} = GRPC.Stub.connect("localhost:50051")
      {:ok, reply} = Echo.Greeter.Stub.say_hello(channel, request)

      # Assert
      assert reply.message == "Hello, Alice!"
    end
  end

  test "get server_info from register" do
    service = Echo.Greeter.Stub.__meta__(:service)
    name = service.__meta__(:name)
    {:ok, server_info} = BeeRpc.Register.get_service(name)
    {:ok, server_info} = BeeRpc.Register.get_service(name, "SayHello")

    {:ok, channel} = GRPC.Stub.connect("#{server_info.address}:#{server_info.port}")
    {:ok, reply} = Echo.Greeter.Stub.say_hello(channel, %Echo.EchoReq{name: "Bob"})

    assert reply.message == "Hello, Bob!"
  end
end
