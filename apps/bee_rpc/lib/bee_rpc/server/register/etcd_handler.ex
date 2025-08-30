defmodule BeeRpc.Server.Register.EtcdHandler do
  @moduledoc """
  handler for etcd register
  """
  use GenServer
  require Record
  require Logger
  alias BeeRpc.ServerInfo
  alias BeeRpc.Server.Register

  Record.defrecordp(:state, conn: nil, lease_id: nil)

  def start_link(opts, conn) do
    GenServer.start_link(__MODULE__, {opts, conn}, name: __MODULE__)
  end

  @impl true
  def init({opts, conn}) do
    Process.flag(:trap_exit, true)
    endpoint = Keyword.get(opts, :endpoint)
    server_infos = Register.get_all_server_infos_from_endpoint(endpoint)
    state = init_server_infos_and_watch(conn, server_infos, opts[:prefix])
    Logger.info("Etcd Register Handler started with state: #{inspect(state)}")
    Process.send_after(self(), :keepalive, 4000)
    {:ok, state}
  end

  @impl true
  def handle_info(:keepalive, state(conn: conn, lease_id: lease_id)) do
    case EtcdEx.keep_alive(conn, lease_id) do
      {:ok, _resp} ->
        Logger.debug("Etcd keep alive success for lease_id: #{lease_id}")
        Process.send_after(self(), :keepalive, 4000)
        {:noreply, state(conn: conn, lease_id: lease_id)}

      {:error, reason} ->
        Logger.error(
          "Etcd keep alive failed for lease_id: #{lease_id}, reason: #{inspect(reason)}"
        )

        {:stop, :keepalive_failed, state(conn: conn, lease_id: lease_id)}
    end
  end

  @impl true
  def terminate(reason, state(conn: conn, lease_id: lease_id)) do
    resp = EtcdEx.revoke(conn, lease_id)

    Logger.info(
      "Etcd Register Handler terminated: #{inspect(reason)}, revoke lease: #{inspect(resp)}"
    )

    :ok
  end

  defp init_server_infos_and_watch(conn, server_infos, prefix) do
    # key => #{prefix}/#{service}/#{host}
    {:ok, %{:ID => lease_id} = _granted} = EtcdEx.grant(conn, 10)

    Enum.each(server_infos, fn %ServerInfo{service: service, host: host} = info ->
      key = Path.join(["/", prefix, service, host])
      value = info |> Map.from_struct() |> JSON.encode!()
      opts = [prev_kv: true, lease: lease_id]
      {:ok, result} = EtcdEx.put(conn, key, value, opts)
      Logger.info("Etcd put result: #{inspect(result)}")
    end)

    state(conn: conn, lease_id: lease_id)
  end
end
