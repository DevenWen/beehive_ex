import Config

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
