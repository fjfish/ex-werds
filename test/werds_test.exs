defmodule WerdzTest do
  use ExUnit.Case
  doctest Werdz

  test "Creates word mask" do
    assert Werdz.hello() == :world
  end
end
