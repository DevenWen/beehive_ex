import Config

# Configure the register module to use
config :bee_rpc,
  client: [
    discover: [
      handler: BeeRpc.Client.Discover.Etcd,
      opts: [
        etcd_url: "http://localhost:2379",
        prefix: "/bee_rpc/dev"
      ]
    ],
    load_balancer: [
      handler: BeeRpc.Client.LoadBalancer.Random
    ]
  ],
  endpoint: [
    handler: BeeRpc.Endpoint,
    opts: [
      start_server: true,
      port: String.to_integer(System.get_env("PORT") || "50051")
    ],
    register: [
      handler: BeeRpc.Server.Register.Etcd,
      opts: [
        etcd_url: "http://localhost:2379",
        prefix: "/bee_rpc/dev"
      ]
    ]
  ]
