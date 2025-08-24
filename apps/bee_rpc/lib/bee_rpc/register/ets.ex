defmodule BeeRpc.Register.ETS do
  @moduledoc """
  ETS implementation of the BeeRpc.Register behaviour.
  """

  @behaviour BeeRpc.Register

  use GenServer
  require Logger

  alias BeeRpc.Server.ServiceInfo

  @doc """
  Starts the ETS register service.
  """
  @impl true
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
  Registers a service with the registry.
  """
  @impl true
  def register_service(service_name, %ServiceInfo{} = service_info) do
    GenServer.call(__MODULE__, {:register_service, service_name, service_info})
  end

  @doc """
  Unregisters a service from the registry.
  """
  @impl true
  def unregister_service(service_name) do
    GenServer.call(__MODULE__, {:unregister_service, service_name})
  end

  @doc """
  Lists all registered services.
  """
  @impl true
  def list_services() do
    GenServer.call(__MODULE__, :list_services)
  end

  @doc """
  Gets information about a specific service.
  """
  @impl true
  def get_service(service_name) do
    GenServer.call(__MODULE__, {:get_service, service_name})
  end

  @impl true
  def get_service(service_name, func_name) do
    GenServer.call(__MODULE__, {:get_service, service_name, func_name})
  end

  @doc """
  Updates service information.
  """
  @impl true
  def update_service(service_name, %ServiceInfo{} = service_info) do
    GenServer.call(__MODULE__, {:update_service, service_name, service_info})
  end

  # GenServer callbacks
  @impl true
  def init(opts) do
    table = :ets.new(:bee_rpc_services, [:set, :public, :named_table])
    server_infos = Keyword.get(opts, :server_infos, [])
    init_server_infos(server_infos, table)
    {:ok, table}
  end

  defp init_server_infos(server_infos, table) do
    Enum.each(server_infos, fn %ServiceInfo{name: name, functions: functions} = info ->
      Logger.info("Registered service #{name} with functions: #{inspect(functions)}")
      :ets.insert(table, {name, info})
      functions |> Enum.each(fn func -> :ets.insert(table, {{name, func}, info}) end)
    end)
  end

  @impl true
  def handle_call({:register_service, service_name, service_info}, _from, table) do
    :ets.insert(table, {service_name, service_info})
    {:reply, :ok, table}
  end

  @impl true
  def handle_call({:unregister_service, service_name}, _from, table) do
    :ets.delete(table, service_name)
    {:reply, :ok, table}
  end

  @impl true
  def handle_call(:list_services, _from, table) do
    services =
      :ets.tab2list(table)
      |> Enum.map(fn {name, info} -> %{info | name: name} end)

    {:reply, {:ok, services}, table}
  end

  @impl true
  def handle_call({:get_service, service_name}, _from, table) do
    case :ets.lookup(table, service_name) do
      [{^service_name, info}] -> {:reply, {:ok, info}, table}
      [] -> {:reply, {:error, :not_found}, table}
    end
  end

  @impl true
  def handle_call({:get_service, service_name, function}, _from, state) do
    case :ets.lookup(state, {service_name, function}) do
      [{{^service_name, ^function}, info}] -> {:reply, {:ok, info}, state}
      [] -> {:reply, {:error, :not_found}, state}
    end
  end

  @impl true
  def handle_call({:update_service, service_name, service_info}, _from, table) do
    case :ets.lookup(table, service_name) do
      [{^service_name, _old_info}] ->
        :ets.insert(table, {service_name, service_info})
        {:reply, :ok, table}

      [] ->
        {:reply, {:error, :not_found}, table}
    end
  end
end
