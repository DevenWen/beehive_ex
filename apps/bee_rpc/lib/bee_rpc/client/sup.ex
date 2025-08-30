defmodule BeeRpc.Client.Sup do
  @moduledoc """
  Supervisor for BeeRpc Client

  Design is
  Sup
   | -- BeeRpc.Discovery (Discovery the gRPC service)

  """
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    config = Application.get_env(:bee_rpc, :client)
    config = Keyword.validate!(config, [:discover, :load_balancer])
    discover = Keyword.validate!(config[:discover], [:handler, opts: []])

    children = discover[:handler].children_spec(discover[:opts])

    # Use :one_for_all strategy as specified in the design
    Supervisor.init(children, strategy: :one_for_all)
  end
end
