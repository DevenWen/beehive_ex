defmodule BeeRpc do
  defmacro __using__(_opts) do
    quote do
      alias BeeRpc.Server.ServiceInfo
    end
  end
end
