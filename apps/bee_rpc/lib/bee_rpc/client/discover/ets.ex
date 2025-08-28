defmodule BeeRpc.Client.Discover.ETS do
  @moduledoc """
  A module for discovering services using ETS.
  """
  @behaviour BeeRpc.Client.Discover
  @ets_table :bee_rpc_services

  @impl true
  def find_service(service, method) do
    case :ets.lookup(@ets_table, {service, method}) do
      [{_, service_info}] -> {:ok, [service_info]}
      [] -> {:error, :service_not_found}
    end
  end
end
