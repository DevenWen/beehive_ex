defmodule BeeRpc.Server.Register.ETS do
  @moduledoc """
  ETS implementation of the BeeRpc.Server.Register behaviour.
  """
  use GenServer
  require Logger

  alias BeeRpc.ServerInfo
  alias BeeRpc.Server.Register
  @ets_table :bee_rpc_services


  def children_spec(opts) do
    [
      %{
        id: BeeRpc.Server.Register.ETS,
        start: {__MODULE__, :start_link, [opts]},
        type: :worker,
        restart: :permanent
      }
    ]
  end

  @doc """
  Starts the ETS register service.
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  # GenServer callbacks
  @impl true
  def init(opts) do
    endpoint = Keyword.get(opts, :endpoint)
    server_infos = Register.get_all_server_infos_from_endpoint(endpoint)
    table = :ets.new(@ets_table, [:set, :public, :named_table])
    init_server_infos(server_infos, table)
    {:ok, table}
  end

  @impl true
  def handle_info(_param, state), do: {:noreply, state}

  defp init_server_infos(server_infos, table) do
    Enum.each(server_infos, fn %ServerInfo{service: name, functions: functions} = info ->
      functions |> Enum.each(fn func -> :ets.insert(table, {{name, func}, info}) end)
    end)
  end
end
