defmodule BeeRpc.Server.Register do
  @moduledoc """
  Behaviour for registering gRPC services with the BeeRpc server.

  This module defines the callback functions that any register implementation must provide.
  Different implementations can use various state management solutions like ETS, ETCD,
  ZooKeeper, Consul, etc.

  Prompt:
  1. we need to define a Register behavior module, design the callback functions for the 'Register'
  2. we can use different state management for the register, like ETS, ETCD, ZooKeeper, Consul, or others
  3. this about the supervisor tree, how to start the register service or restart the register service
  """

  alias BeeRpc.ServerInfo
  alias BeeUtils.IpUtil

  @spec get_all_server_infos_from_endpoint(endpoint :: module()) :: [ServerInfo.t()]
  def get_all_server_infos_from_endpoint(endpoint) do
    ip_address = IpUtil.get_ip() || "localhost"
    port = Application.get_env(:bee_rpc, :endpoint)[:opts][:port] || 50050

    endpoint.__meta__(:servers)
    |> Enum.map(fn server -> server.__meta__(:service) end)
    |> Enum.map(fn service ->
      name = service.__meta__(:name)
      functions = service.__rpc_calls__() |> Enum.map(&elem(&1, 0)) |> Enum.map(&Atom.to_string/1)

      %ServerInfo{
        service: name,
        host: ip_address,
        port: port,
        metadata: %{},
        functions: functions
      }
    end)
  end

  @doc """
  Retrieves service information by service name.

  Returns `{:ok, %ServerInfo{}}` if the service is found, `{:error, :not_found}` otherwise.
  """
  @callback get_service(service :: String.t()) :: {:ok, ServerInfo.t()} | {:error, :not_found}

  @doc """
  Retrieves service information by service name and function name.

  Returns `{:ok, %ServerInfo{}}` if the service and function are found, `{:error, :not_found}` otherwise.
  """
  @callback get_service(service :: String.t(), function :: String.t()) :: {:ok, ServerInfo.t()} | {:error, :not_found}
end
