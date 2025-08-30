defmodule BeeRpc.Client.Discover.EtcdTest do
  use ExUnit.Case
  doctest BeeRpc.Client.Discover.Etcd
  alias BeeRpc.Client.Discover.Etcd

  test "etcd register and update" do
    {:ok, client_pid} = start_supervised(BeeRpc.Client.Sup)
    Process.exit(client_pid, :shutdown)
    assert {:error, :service_or_function_not_found} = Etcd.find_service("echo.Greeter", "SayHello")
    {:ok, _server_pid} = start_supervised(BeeRpc.Server.Sup)
    Process.sleep(100)
    assert {:ok, [_]} = Etcd.find_service("echo.Greeter", "SayHello")
  end
end
