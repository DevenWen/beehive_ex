defmodule BeeRpcTest do
  use ExUnit.Case
  doctest BeeRpc

  setup do
    # Start the BeeRpc application for integration tests
    {:ok, _pid} = start_supervised(BeeRpc.Server.Sup)
    {:ok, _pid} = start_supervised(BeeRpc.Client.Sup)
    :ok
  end

  describe "gRPC Greeter service" do
    test "say_hello returns a greeting via RPC call" do
      # Arrange
      request = %Echo.EchoReq{name: "Alice"}

      # Act
      {:ok, channel} = GRPC.Stub.connect("localhost:50051")
      {:ok, reply} = Echo.Greeter.Stub.Handler.say_hello(channel, request)

      # Assert
      assert reply.message == "Hello, Alice!"
    end
  end


  test "rpc with discover and loadbalance" do
    assert {:ok, %{message: "Hello, Charlie!"}} =
             Echo.Greeter.Stub.say_hello(%Echo.EchoReq{name: "Charlie"})
  end

  @tag skip: true
  test "test multiplexing" do
    # cool! it works!
    {:ok, channel} = GRPC.Stub.connect("localhost:50051")

    1..1000
    |> Enum.map(fn i ->
      Task.async(fn ->
        {:ok, reply} =
          Echo.Greeter.Stub.Handler.say_hello(channel, %Echo.EchoReq{name: "Bob#{i}"})
        assert reply.message == "Hello, Bob#{i}!"
      end)
    end)
    |> Enum.map(&Task.await/1)
  end
end
