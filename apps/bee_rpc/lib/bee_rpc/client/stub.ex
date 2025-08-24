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
    quote do
      use GRPC.Stub, unquote(opts)
      # TODO

      def __meta__(:service) do
        unquote(opts)[:service]
      end
    end
  end
end
