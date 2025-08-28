defmodule BeeRpc.Client.ChannelManager do
  @moduledoc """
  Manages gRPC channels for BeeRPC clients.

  Since gRPC is multiplexed, we can reuse channels for multiple requests to the same server.
  """
  alias BeeRpc.ServerInfo

  @spec get_channel(server_info :: ServerInfo.t()) :: {:ok, GRPC.Channel.t()} | {:error, any()}
  def get_channel(server_info) do
    # TODO wait for reuse channel
    # 1. need to check the channel is alive or not
    # 2. need a gen_server to manage the channel
    {:ok, channel} = GRPC.Stub.connect("#{server_info.host}:#{server_info.port}")
    {:ok, channel}
  end

end
