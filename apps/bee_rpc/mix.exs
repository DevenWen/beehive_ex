defmodule BeeRpc.MixProject do
  use Mix.Project

  def project do
    [
      app: :bee_rpc,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: [
        "gen.grpc.proto": [
          "cmd bash -c 'protoc --elixir_out=plugins=grpc:./lib --proto_path=./priv ./priv/**/*.proto && sed -i \"s#use GRPC.Stub,#use BeeRpc.Client.Stub,#g\" lib/services/*.pb.ex'"
        ]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:protobuf, "~> 0.14"},
      {:nimble_pool, "~> 1.0"},
      {:grpc, "~> 0.10"},
      {:etcdex, "~> 2.0"},
      {:bee_utils, in_umbrella: true}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
