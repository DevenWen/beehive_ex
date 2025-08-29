defmodule BeeRpcTest do
  use ExUnit.Case
  doctest BeeRpc

  setup do
    # Start the BeeRpc application for integration tests
    {:ok, _pid} = start_supervised(BeeRpc.Server.Sup)
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

  test "get server_info from register" do
    service = Echo.Greeter.Stub.__meta__(:service)
    name = service.__meta__(:name)

    with {:ok, server_infos} <- BeeRpc.Client.Discover.find_service(name, "SayHello"),
         {:ok, server_info} <- BeeRpc.Client.LoadBalancer.choose(server_infos),
         {:ok, channel} <- BeeRpc.Client.ChannelManager.get_channel(server_info) do
      {:ok, reply} = Echo.Greeter.Stub.Handler.say_hello(channel, %Echo.EchoReq{name: "Bob"})
      assert reply.message == "Hello, Bob!"
    end
  end

  test "rpc with discover and loadbalance" do
    assert {:ok, %{message: "Hello, Charlie!"}} =
             Echo.Greeter.Stub.say_hello(%Echo.EchoReq{name: "Charlie"})
  end

  test "test multiplexing" do
    # 结论：支持多路复用。cool!
    {:ok, channel} = GRPC.Stub.connect("localhost:50051")

    1..1000
    |> Enum.map(fn i ->
      Task.async(fn ->
        {:ok, reply} = Echo.Greeter.Stub.Handler.say_hello(channel, %Echo.EchoReq{name: "Bob#{i}"})
        assert reply.message == "Hello, Bob#{i}!"
      end)
    end)
    |> Enum.map(&Task.await/1)
  end
end
