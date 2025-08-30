defmodule BeeRpc.Client.Discover.Etcd do
  @moduledoc """
  A module for discovering services using Etcd.

  1. Get all services from Etcd and store them in ETS table.
  2. watch the Etcd for changes and update the ETS table accordingly.
  3. Discover with find the service by service name and method.

  TODO
  1. consider support :progress_notify, if etcd server remote CPU is high, maybe this process should check health of etcd server.
  """
  @behaviour BeeRpc.Client.Discover
  use GenServer
  require Record
  alias BeeRpc.ServerInfo
  require Logger
  @ets :bee_rpc_client_discover_ets
  @etcd_conn BeeRpc.Client.Discover.Etcd.Client

  Record.defrecordp(:state, conn: nil, revision: 0)

  @impl true
  def find_service(service, method) do
    case :ets.lookup(@ets, {service, method}) do
      [_ | _] = result ->
        result
        |> Enum.map(fn {_, _host, _port, _version, server_info} -> server_info end)
        |> then(&{:ok, &1})

      [] ->
        {:error, :service_or_function_not_found}
    end
  end

  @impl true
  def children_spec(opts) do
    opts =
      Keyword.validate!(opts, [:endpoint, etcd_url: "http://localhost:2379", prefix: "/bee_rpc"])

    uri = URI.parse(opts[:etcd_url])
    schema = if uri.scheme == "https", do: :https, else: :http
    etcd_endpoint = {schema, uri.host, uri.port, []}

    [
      {
        EtcdEx,
        name: @etcd_conn, endpoint: etcd_endpoint
      },
      %{
        id: BeeRpc.Client.Discover.ETCD,
        start: {__MODULE__, :start_link, [opts, @etcd_conn]},
        type: :worker,
        restart: :transient
      }
    ]
  end

  def start_link(opts, conn) do
    GenServer.start_link(__MODULE__, {opts, conn}, name: __MODULE__)
  end

  @impl true
  def init({opts, conn}) do
    Logger.info("Starting Etcd Discover with opts: #{inspect(opts)}")
    Process.flag(:trap_exit, true)
    # 1. init ets table, ets table should be like a bag
    :ets.new(@ets, [:bag, :protected, :named_table, read_concurrency: true])
    # 2. init server_info state
    # 3. watch the etcd for changes
    with {:ok, revision} <- init_server_info_from_etcd(conn, opts[:prefix]),
         :ok <- init_watch(conn, revision, opts[:prefix]) do
      {:ok, state(conn: conn, revision: revision)}
    end
  end

  @impl true
  def handle_info({:etcd_watch_created, watch_ref}, state) do
    Logger.info("Etcd watch created with ref: #{inspect(watch_ref)}")
    {:noreply, state}
  end

  @doc """
  response example: see https://hexdocs.pm/etcdex/EtcdEx.html#watch/5
  """
  @impl true
  def handle_info(
        {:etcd_watch_notify, _watch_ref, %{header: %{revision: revision}}},
        state(revision: current_revision) = state
      )
      when current_revision > revision do
    Logger.warning(
      "Etcd watch notify with old revision: #{revision}, current revision: #{current_revision}, response"
    )

    {:noreply, state}
  end

  def handle_info(
        {:etcd_watch_notify, _watch_ref, %{header: %{revision: revision}} = response},
        state
      ) do
    Logger.debug("Etcd watch notify with revision: #{revision}, response: #{inspect(response)}")
    Enum.each(response.events, fn event -> :ok = handle_etcd_event(event) end)
    {:noreply, state(state, revision: revision)}
  end

  @impl true
  def handle_info({:etcd_watch_error, reason}, state) do
    Logger.info("Etcd watch error: #{inspect(reason)}")
    {:stop, :etcd_watch_created, state}
  end

  @impl true
  def terminate(reason, state(conn: conn)) do
    Logger.info("Etcd watch terminated: #{inspect(reason)}")
    EtcdEx.cancel_watch(conn, self())
    :ok
  end

  defp handle_etcd_event(%{type: :PUT, kv: %{key: key, value: value, version: version}}) do
    # 1. add all server_info to ets
    # 2. delete all server_info which version < version input
    case ServerInfo.from_json_str(value, version) do
      {:ok, %ServerInfo{host: host, port: port, version: version} = info} ->
        Logger.info("Etcd PUT event handled for key: #{key}, version: #{version}")
        insert_server_info_to_ets(info)
        delete_server_info_from_ets(host, port, version)
        :ok

      {:error, reason} ->
        Logger.error(
          "Failed to parse server info from etcd value: #{value}, reason: #{inspect(reason)}"
        )
    end
  end

  defp handle_etcd_event(%{type: :DELETE, kv: %{key: key, version: version}}) do
    # 1. list all server_info from ets , and delete there it.
    Logger.info("Etcd DELETE event: key: #{key}, version: #{version}")
    [port_str, host | _] = Path.split(key) |> Enum.reverse()
    port = String.to_integer(port_str)
    delete_server_info_from_ets(host, port, version)
    :ok
  end

  defp init_watch(conn, revision, prefix) do
    {:ok, ref} = EtcdEx.watch(conn, self(), prefix, start_revision: revision, prefix: true)
    Logger.info("Etcd watch started with ref: #{inspect(ref)}, start_revision: #{revision}")
  end

  defp init_server_info_from_etcd(conn, prefix) do
    # 1. get all services from etcd
    # 2. parse the services to ServerInfo struct
    # 3. return the ServerInfo struct
    prefix = Path.join("/", prefix)
    {:ok, %{header: %{revision: revision}, kvs: kvs}} = EtcdEx.get(conn, prefix, prefix: true)

    kvs
    |> Enum.map(fn %{key: _key, value: value, version: version} ->
      case ServerInfo.from_json_str(value, version) do
        {:ok, info} ->
          insert_server_info_to_ets(info)
          :ok

        {:error, reason} ->
          Logger.error(
            "Failed to parse server info from etcd value: #{value}, reason: #{inspect(reason)}"
          )

          {:error, reason}
      end
    end)
    |> Enum.all?(fn result -> result == :ok end)
    |> case do
      true -> {:ok, revision}
      false -> {:error, :failed_to_init_from_etcd}
    end
  end

  defp insert_server_info_to_ets(
         %ServerInfo{
           service: service,
           functions: functions,
           host: host,
           port: port,
           version: version
         } = info
       ) do
    Enum.each(functions, fn func ->
      :ets.insert(@ets, {{service, func}, host, port, version, info})
    end)
  end

  defp delete_server_info_from_ets(host, port, 0) do
    Logger.info("delete server info from ets: host=#{host}, port=#{port}, version=0")

    :ets.tab2list(@ets)
    |> Enum.filter(fn
      {{_service, _func}, ^host, ^port, _version, _info} -> true
      _ -> false
    end)
    |> Enum.each(fn term ->
      :ets.delete_object(@ets, term)
    end)
  end

  defp delete_server_info_from_ets(host, port, version) when version > 0 do
    Logger.info("delete server info from ets: host=#{host}, port=#{port}, version=#{version}")

    :ets.tab2list(@ets)
    |> Enum.filter(fn
      {{_service, _func}, ^host, ^port, old_version, _info} when old_version < version -> true
      _ -> false
    end)
    |> Enum.each(fn term ->
      :ets.delete_object(@ets, term)
    end)
  end
end
