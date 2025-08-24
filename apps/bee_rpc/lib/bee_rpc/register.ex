defmodule BeeRpc.Register do
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

  alias BeeRpc.Server.ServiceInfo
  alias BeeUtils.IpUtil
  require Logger

  # Get the configured register module from the application config
  @register_module Application.compile_env(:bee_rpc, :register)[:module] ||
                     BeeRpc.Register.ETS

  @doc """
  Callback to start the register service.
  """
  @callback start_link(opts :: Keyword.t()) :: {:ok, pid()} | {:error, reason :: term()}

  @doc """
  Callback to register a service with the registry.
  """
  @callback register_service(service_name :: String.t(), service_info :: ServiceInfo.t()) ::
              :ok | {:error, reason :: term()}

  @doc """
  Callback to unregister a service from the registry.
  """
  @callback unregister_service(service_name :: String.t()) :: :ok | {:error, reason :: term()}

  @doc """
  Callback to list all registered services.
  """
  @callback list_services() :: {:ok, [ServiceInfo.t()]} | {:error, reason :: term()}

  @doc """
  Callback to get information about a specific service.
  """
  @callback get_service(service_name :: String.t()) ::
              {:ok, ServiceInfo.t()} | {:error, reason :: term()}

  @doc """
  Callback to get information about a specific service and function
  """
  @callback get_service(service_name :: String.t(), func_name :: String.t()) ::
              {:ok, ServiceInfo.t()} | {:error, reason :: term()}
  @doc """
  Callback to update service information.
  """
  @callback update_service(service_name :: String.t(), service_info :: ServiceInfo.t()) ::
              :ok | {:error, reason :: term()}

  @doc """
  Starts the configured register service.
  """
  def start_link() do
    # find the server_info all ready registered in the endpoint
    server_infos =
      Application.get_env(:bee_rpc, :endpoint)[:module]
      |> get_all_server_infos()

    opts = Application.get_env(:bee_rpc, :register)[:opts] || []
    opts = Keyword.put(opts, :server_infos, server_infos)
    @register_module.start_link(opts)
  end

  @doc """
  Registers a service with the registry using the configured implementation.
  """
  def register_service(service_name, service_info) do
    @register_module.register_service(service_name, service_info)
  end

  @doc """
  Unregisters a service from the registry using the configured implementation.
  """
  def unregister_service(service_name) do
    @register_module.unregister_service(service_name)
  end

  @doc """
  Lists all registered services using the configured implementation.
  """
  def list_services() do
    @register_module.list_services()
  end

  @doc """
  Gets information about a specific service using the configured implementation.
  """
  def get_service(service_name) do
    @register_module.get_service(service_name)
  end

  def get_service(service_name, func_name) do
    @register_module.get_service(service_name, func_name)
  end

  @doc """
  Updates service information using the configured implementation.
  """
  def update_service(service_name, service_info) do
    @register_module.update_service(service_name, service_info)
  end

  @doc """
  Defines the child specification for the register service.
  This allows it to be started under a supervisor.
  """
  def child_spec() do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  defp get_all_server_infos(module) do
    # module is an GRPC Endpoint
    ip_address = IpUtil.get_ip() || "localhost"
    port = Application.get_env(:bee_rpc, :endpoint)[:opts][:port] || 50050

    module.__meta__(:servers)
    |> Enum.map(fn server -> server.__meta__(:service) end)
    |> Enum.map(fn service ->
      name = service.__meta__(:name)
      functions = service.__rpc_calls__() |> Enum.map(&elem(&1, 0)) |> Enum.map(&Atom.to_string/1)

      %ServiceInfo{
        name: name,
        address: ip_address,
        port: port,
        metadata: %{},
        functions: functions
      }
    end)
    |> tap(fn server_infos ->
      Logger.info("Discovered services: #{inspect(server_infos)}")
    end)
  end
end
