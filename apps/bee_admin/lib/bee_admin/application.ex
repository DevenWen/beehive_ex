defmodule BeeAdmin.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      BeeAdminWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:bee_admin, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: BeeAdmin.PubSub},
      # Start a worker by calling: BeeAdmin.Worker.start_link(arg)
      # {BeeAdmin.Worker, arg},
      # Start to serve requests, typically the last entry
      BeeAdminWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BeeAdmin.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BeeAdminWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
