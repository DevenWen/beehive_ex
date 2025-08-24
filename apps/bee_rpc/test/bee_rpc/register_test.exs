defmodule BeeRpc.RegisterTest do
  use ExUnit.Case
  use BeeRpc
  doctest BeeRpc.Register
  alias BeeRpc.Register

  setup do
    # Start the BeeRpc application for integration tests
    {:ok, _pid} = start_supervised(BeeRpc.Server.Sup)
    :ok
  end

  test "start the register service" do
    # start the register service
    {:error, :not_found} = Register.get_service("Echo.Greeter")
    {:ok, %ServiceInfo{}} = Register.get_service("echo.Greeter")
    {:ok, %ServiceInfo{}} = Register.get_service("echo.Greeter", "SayHello")
  end
end
