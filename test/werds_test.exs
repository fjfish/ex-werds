defmodule WerdsTest do
  use ExUnit.Case
  doctest Werds

  describe "word_mask" do
    test "simplest single ." do
      assert Werds.make_mask("banana", ".") == "^[banana]$"
    end

    test "2 ." do
      assert Werds.make_mask("banana", "..") == "^[banana][banana]$"
    end

    test "removes letters from regexp if they appear in match string"  do
      assert Werds.make_mask("banana", "..n") == "^[baana][baana]n$"
      assert Werds.make_mask("banana", "n.b.n") == "^n[aaa]b[aaa]n$"
    end
  end

  describe "words" do

    test "it finds some" do
      assert Werds.words("dredge", "d..d") == ["deed"]
    end

  end
end
