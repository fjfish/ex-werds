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

    test "it finds a word" do
      assert Werds.words("dredge", "d..d") == ["deed"]
    end

    test "it doesn't double up letters" do
      assert Enum.find(Werds.words("ranger", "....."),&(&1 == "agana")) == nil
    end

    test "it doesn't allow letters that aren't in source word" do
      assert Werds.words("dredge", "..a.") == {:error, "Source word does not have letters 'a'"}
    end

    test "it doesn't allow more letters than the source word" do
      assert Werds.words("dredge", "dredger") == {:error, "Matcher has too many letters"}
    end

    test "it doesn't allow source letters to be used more than once" do
      assert Werds.words("elegant", "tall") == []
    end
  end

  describe "options" do

    test "it matches case when option not turned on" do
      assert Werds.words("AFAIK", "AFAIK",[]) == ["AFAIK"]
      assert Werds.words("AFAIK", "afaik",[]) == []
    end

    test "it defaults caseless" do
      assert Werds.words("AFAIK", "AFAIK") == ["AFAIK"]
      assert Werds.words("AFAIK", "afaik") == ["AFAIK"]
    end
  end
end
