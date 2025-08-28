defmodule BeeRpc.Client.LoadBalancer do
  @moduledoc """
  Load balancer module for BeeRpc.Client.
  """
  alias BeeRpc.ServerInfo

  @callback choose(server_infos :: [ServerInfo.t()]) ::
              {:ok, ServerInfo.t()} | {:error, :no_server_available}

  def choose(server_infos) do
    handler = Application.get_env(:bee_rpc, :client)[:load_balancer][:handler] || BeeRpc.Client.LoadBalancer.Random
    handler.choose(server_infos)
  end
end
