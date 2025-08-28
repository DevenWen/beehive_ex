import Config

# Configure the register module to use
config :bee_rpc,
  client: [
    discover: [
      handler: BeeRpc.Client.Discover.ETS
    ],
    load_balancer: [
      handler: BeeRpc.Client.LoadBalancer.Random
    ]
  ],
  endpoint: [
    handler: BeeRpc.Endpoint,
    opts: [
      start_server: true,
      port: 50051
    ],
    register: [
      handler: BeeRpc.Server.Register.ETS,
      opts: []
    ]
  ]
