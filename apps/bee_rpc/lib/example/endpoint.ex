defmodule BeeRpc.Endpoint do
  use GRPC.Endpoint

  intercept GRPC.Server.Interceptors.Logger

  run BeeRpc.GreeterServer
end
