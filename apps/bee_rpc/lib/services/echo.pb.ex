defmodule Echo.EchoReq do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field(:name, 1, type: :string)
end

defmodule Echo.EchoReply do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field(:message, 1, type: :string)
end

defmodule Echo.Greeter.Service do
  @moduledoc false

  use GRPC.Service, name: "echo.Greeter", protoc_gen_elixir_version: "0.15.0"

  rpc(:SayHello, Echo.EchoReq, Echo.EchoReply)
end

defmodule Echo.Greeter.Stub do
  @moduledoc false

  use BeeRpc.Client.Stub, service: Echo.Greeter.Service
end
