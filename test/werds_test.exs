defmodule WerdsTest do
  use ExUnit.Case
  doctest Werds

  test "Creates word mask" do
    assert Werds.hello() == :world
  end
end
