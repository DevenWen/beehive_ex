# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :bee_admin,
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :bee_admin, BeeAdminWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: BeeAdminWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: BeeAdmin.PubSub,
  live_view: [signing_salt: "QGMmXFnl"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

# Configure the register module to use
config :bee_rpc,
  register: [
    module: BeeRpc.Register.ETS
  ],
  endpoint: [
    module: BeeRpc.Endpoint,
    opts: [
      port: 50051,
      start_server: true
    ]
  ],
  client: [
    opts: [
      pool_size: 5,
      pool_max_overflow: 10
    ]
  ]
