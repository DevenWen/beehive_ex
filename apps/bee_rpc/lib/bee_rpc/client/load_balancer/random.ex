defmodule BeeRpc.Client.LoadBalancer.Random do

  @behaviour BeeRpc.Client.LoadBalancer

  @impl true
  def choose([]), do: {:error, :no_server_available}
  def choose([server_info]), do: {:ok, server_info}
  def choose(server_infos), do: {:ok, Enum.random(server_infos)}
end
