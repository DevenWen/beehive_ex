defmodule BeeRpc.Client.Stub do
  @moduledoc """
  A wrapper module for GRPC.Stub
  1. This module will setup then grpc discovery, and get the channel for GRPC Stud

  here is the detail:
  1. setup a module use GRPC.Stub
  2. rewrite all the functions from the GRPC.Stub module to add the channel automatically
  3. use the BeeRpc.Discovery to get the channel , Pooling the channel
  """

  defmacro __using__(opts) do
    opts = Keyword.validate!(opts, [:service])

    quote bind_quoted: [opts: opts] do
      service_mod = opts[:service]
      service_name = service_mod.__meta__(:name)

      defmodule Handler do
        use GRPC.Stub, service: service_mod
      end

      Enum.each(service_mod.__rpc_calls__(), fn {name, {_, req_stream}, _res, _opts} ->
        func_name = name |> to_string |> Macro.underscore()

        if req_stream do
          def unquote(String.to_atom(func_name))(opts \\ []) do
            with {:ok, server_infos} <-
                   BeeRpc.Client.Discover.find_service(
                     unquote(service_name),
                     unquote(to_string(name))
                   ),
                 {:ok, server_info} <- BeeRpc.Client.LoadBalancer.choose(server_infos),
                 {:ok, channel} <- BeeRpc.Client.ChannelManager.get_channel(server_info) do
              apply(Handler, unquote(String.to_atom(func_name)), [channel, opts])
            end
          end
        else
          def unquote(String.to_atom(func_name))(request, opts \\ []) do
            with {:ok, server_infos} <-
                   BeeRpc.Client.Discover.find_service(
                     unquote(service_name),
                     unquote(to_string(name))
                   ),
                 {:ok, server_info} <- BeeRpc.Client.LoadBalancer.choose(server_infos),
                 {:ok, channel} <- BeeRpc.Client.ChannelManager.get_channel(server_info) do
              apply(Handler, unquote(String.to_atom(func_name)), [channel, request, opts])
            end
          end
        end
      end)

      def __meta__(:service) do
        unquote(opts)[:service]
      end
    end
  end
end
