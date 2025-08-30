defmodule BeeRpc.Client.ChannelManager do
  @moduledoc """
  Manages gRPC channels for BeeRPC clients.

  Since gRPC is multiplexed, we can reuse channels for multiple requests to the same server.
  """
  alias BeeRpc.ServerInfo
  require Logger

  @spec execute_by_channel(server_info :: ServerInfo.t(), callback :: function) :: {:ok, GRPC.Channel.t()} | {:error, any()}
  def execute_by_channel(server_info, callback) do
    # TODO wait for reuse channel
    # 1. need to check the channel is alive or not
    # 2. need a gen_server to manage the channel
    case GRPC.Stub.connect("#{server_info.host}:#{server_info.port}") do
      {:ok, channel} ->
        try do
          callback.(channel)
        after
          GRPC.Stub.disconnect(channel)
        end

      {:error, reason} ->
        Logger.warning(
          "Failed to connect to server: #{server_info.host}:#{server_info.port} #{inspect(reason)}"
        )

        {:error, reason}
    end
  end
end
