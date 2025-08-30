defmodule BeeRpc.Server.Register.EtcdTest do
	use ExUnit.Case
	doctest BeeRpc.Server.Register.Etcd
  @etcd_conn :test_etcd_conn

  setup do
    {:ok, _pid} = start_supervised(BeeRpc.Server.Sup)
    EtcdEx.start_link(name: @etcd_conn)
    {:ok, %{etcd_conn: @etcd_conn}}
  end

  test "ensure register into etcd", %{etcd_conn: conn} do
    assert {:ok, %{count: 1, kvs: [%{value: value, key: key}]}} = EtcdEx.get(conn, "/bee_rpc", [prefix: true])
    assert key =~ "/bee_rpc/dev/echo.Greeter"
    assert value =~ "\"service\":\"echo.Greeter\""
  end

end
