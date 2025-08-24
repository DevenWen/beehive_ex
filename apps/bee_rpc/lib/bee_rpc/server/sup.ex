defmodule BeeRpc.Server.Sup do
  @moduledoc """
  Supervisor for BeeRpc Register Processes.

  Design is
  Supervisor
    | -- BeeRpc.Endpoint (gRPC Endpoint)
    | -- BeeRpc.Register (ETS based register)

  restart strategy is :one_for_all
  """

  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    children = [
      endpoint_conf(),
      register_conf()
    ]

    # Use :one_for_all strategy as specified in the design
    Supervisor.init(children, strategy: :one_for_all)
  end

  defp endpoint_conf() do
    module = Application.get_env(:bee_rpc, :endpoint)[:module]
    opts = Application.get_env(:bee_rpc, :endpoint)[:opts] || [port: 50051, start_server: true]

    {
      GRPC.Server.Supervisor,
      [
        endpoint: module,
        port: opts[:port],
        start_server: opts[:start_server]
      ]
    }
  end

  defp register_conf() do
    BeeRpc.Register.child_spec()
  end
end
