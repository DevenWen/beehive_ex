# BeeProto

1. define all the protol for then project.
2. it will gen Protobuf into Elixir Module.

## Usage
1. install protoc-gen-elixir
```
mix escript.install hex protobuf
```
2. add into $PATH
```
export PATH="$HOME/.mix/escripts:$PATH"
```
3. gen
```
mix gen.proto
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `bee_proto` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:bee_proto, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/bee_proto>.

