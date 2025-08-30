defmodule BeeRpc.Server.Register.Etcd do
  @moduledoc """
  Etcd implementation of the BeeRpc.Server.Register behaviour.
  """

  @behaviour BeeRpc.Server.Register
  use Supervisor
  require Logger

  alias BeeRpc.Server.Register.EtcdHandler
  @etcd_conn BeeRpc.Server.Register.Etcd.Client

  @impl true
  def children_spec(opts) do
    [
      %{
        id: BeeRpc.Server.Register.Etcd,
        start: {__MODULE__, :start_link, [opts]},
        type: :supervisor,
        restart: :permanent
      }
    ]
  end

  # callback
  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(opts) do
    opts =
      Keyword.validate!(opts, [:endpoint, etcd_url: "http://localhost:2379", prefix: "/bee_rpc"])

    Logger.info("Starting Etcd Register with opts: #{inspect(opts)}")
    uri = URI.parse(opts[:etcd_url])
    schema = if uri.scheme == "https", do: :https, else: :http
    etcd_endpoint = {schema, uri.host, uri.port, []}

    children = [
      {EtcdEx, name: @etcd_conn, endpoint: etcd_endpoint},
      %{
        id: EtcdHandler,
        start: {EtcdHandler, :start_link, [opts, @etcd_conn]},
        type: :worker,
        restart: :transient
      }
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
