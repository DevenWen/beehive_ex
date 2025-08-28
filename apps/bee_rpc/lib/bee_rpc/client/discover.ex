defmodule BeeRpc.Client.Discover do
  @moduledoc """
  A module for discovering services.
  """
  alias BeeRpc.ServerInfo

  @doc """
  Finds a service by its name and method.

  ## Parameters
  - service: The name of the service to find
  - method: The method of the service to find
  """
  @callback find_service(service :: String.t(), method :: String.t()) :: {:ok, [ServerInfo.t()]} | {:error, :service_not_found}

  def find_service(service, method) do
    handler = Application.get_env(:bee_rpc, :client)[:discover][:handler]
    handler.find_service(service, method)
  end
end
