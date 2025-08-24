defmodule BeeProtoTest do
  use ExUnit.Case
  doctest BeeProto

  test "greets the world" do
    assert BeeProto.hello() == :world
  end
end
