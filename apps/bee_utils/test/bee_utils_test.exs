defmodule BeeUtilsTest do
  use ExUnit.Case
  doctest BeeUtils

  test "greets the world" do
    assert BeeUtils.hello() == :world
  end
end
