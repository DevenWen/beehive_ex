defmodule BeeRpc.Client.Sup do
  @moduledoc """
  Supervisor for BeeRpc Client

  Design is
  Supe
   | -- BeeRpc.Client.Pool (Pooling the gRPC connection)
   | -- BeeRpc.Discovery (Discovery the gRPC service)

  """
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    children = [
    ]

    # Use :one_for_all strategy as specified in the design
    Supervisor.init(children, strategy: :one_for_all)
  end

end
