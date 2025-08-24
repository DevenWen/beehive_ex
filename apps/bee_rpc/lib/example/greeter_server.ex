defmodule BeeRpc.GreeterServer do
  use GRPC.Server, service: Echo.Greeter.Service

  def say_hello(%Echo.EchoReq{name: name}, _stream) do
    GRPC.Stream.unary(%Echo.EchoReq{name: name})
    |> GRPC.Stream.map(fn _req ->
      message = "Hello, #{name}!"
      %Echo.EchoReply{message: message}
    end)
    |> GRPC.Stream.run()
  end
end
