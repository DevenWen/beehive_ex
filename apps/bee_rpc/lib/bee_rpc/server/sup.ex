defmodule BeeRpc.Server.Sup do
  @moduledoc """
  Supervisor for BeeRpc Register Processes.

  Design is
  Supervisor
    | -- BeeRpc.Endpoint (gRPC Endpoint)
    | -- BeeRpc.Server.Register (ETS based register)

  restart strategy is :one_for_all
  """

  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    config = Application.get_env(:bee_rpc, :endpoint) || []

    config =
      Keyword.validate!(config, [:handler, :register, opts: [port: 50051, start_server: true]])

    register =
      Keyword.validate!(config[:register], [:handler, opts: []])

    register_opts =
      Keyword.put(register[:opts], :endpoint, config[:handler])

    children = [
      {
        GRPC.Server.Supervisor,
        [
          endpoint: config[:handler],
          start_server: config[:opts][:start_server],
          port: config[:opts][:port],
        ]
      }
    ] ++ register[:handler].children_spec(register_opts)

    # Use :one_for_all strategy as specified in the design
    Supervisor.init(children, strategy: :one_for_all)
  end
end
