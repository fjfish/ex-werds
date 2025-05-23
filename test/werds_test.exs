defmodule WerdsTest do
  @moduledoc false

  use ExUnit.Case
  doctest Werds

  describe "word_mask" do
    test "simplest single ." do
      assert Werds.make_mask("banana", ".") == "^[banana]$"
    end

    test "2 ." do
      assert Werds.make_mask("banana", "..") == "^[banana][banana]$"
    end

    test "removes letters from regexp if they appear in match string" do
      assert Werds.make_mask("banana", "..n") == "^[baana][baana]n$"
      assert Werds.make_mask("banana", "n.b.n") == "^n[aaa]b[aaa]n$"
    end
  end

  describe "words" do
    test "it finds a word" do
      assert Werds.words("dredge", "d..d") == ["deed"]
    end

    test "it doesn't double up letters" do
      assert Enum.find(Werds.words("ranger", "....."), &(&1 == "agana")) == nil
    end

    test "it doesn't allow letters that aren't in source word" do
      assert Werds.words("dredge", "..a.") == {:error, "Source word does not have letters 'a'"}
    end

    test "it doesn't allow more letters than the source word" do
      assert Werds.words("dredge", "dredger") == {:error, "Matcher has too many letters"}
    end

    test "it doesn't allow source letters to be used more than once" do
      assert Werds.words("elegant", "tall") ==
               {:error, "Matcher uses source letters too many times"}
    end
  end

  describe "options" do
    test "it matches case when option not turned on" do
      assert Werds.words("AFAIK", "AFAIK", []) == ["AFAIK"]
      assert Werds.words("AFAIK", "afaik", []) == []
    end

    test "it defaults caseless" do
      assert Werds.words("AFAIK", "AFAIK") == ["AFAIK"]
      assert Werds.words("AFAIK", "afaik") == ["AFAIK"]
    end

    test "proper names" do
      assert Werds.words("pole", "p...") == ~w(Pole pole)
      assert Werds.words("pole", "p...", []) == ~w(pole)
      assert Werds.words("pole", "p...", [:proper_names]) == ~w(Pole)
      assert Werds.words("aids", "a...", [:proper_names]) == []
    end

    test "acronyms" do
      assert Werds.words("aids", "a...") == ~w(AIDS aids)
      assert Werds.words("aids", "a...", [:acronyms]) == ~w(AIDS)
    end

    test "standard" do
      assert Werds.words("aids", "a...") == ~w(AIDS aids)
      assert Werds.words("aids", "a...", [:standard]) == ~w(aids)
    end
  end

  test "anagrams" do
    assert Werds.anagrams("trashed") == ~w(dearths hardest hatreds threads trashed)
    assert Werds.anagrams("trashed   ") == ~w(dearths hardest hatreds threads trashed)
  end

  describe "wordle suggestsions" do
    test "it finds a word" do
      letters = %{1 => "a", 2 => "p", 3 => "", 4 => "", 5 => ""}
      keys = %{"a" => :correct, "p" => :correct, "l" => :default, "x" => :incorrect}
      assert Enum.member?(Werds.wordle_suggestions(letters, keys), "apple")
    end

    test "it handles no incorrect letters a word" do
      letters = %{1 => "a", 2 => "p", 3 => "", 4 => "", 5 => ""}
      keys = %{"a" => :correct, "p" => :correct, "l" => :default}
      assert Enum.member?(Werds.wordle_suggestions(letters, keys), "apple")
    end

    test "only returns words that are 5 long" do
      letters = %{1 => "a", 2 => "p", 3 => "", 4 => "", 5 => ""}
      keys = %{"a" => :correct, "p" => :correct, "l" => :default}
      assert Enum.max(Enum.map(Werds.wordle_suggestions(letters, keys), &String.length/1)) == 5
      assert Enum.min(Enum.map(Werds.wordle_suggestions(letters, keys), &String.length/1)) == 5
    end

    test "only lower case words returned" do
      letters = %{1 => "", 2 => "", 3 => "", 4 => "a", 5 => ""}

      keys = %{
        "a" => :correct,
        "d" => :incorrect,
        "e" => :incorrect,
        "m" => :incorrect,
        "r" => :misplaced
      }

      assert Enum.find(Werds.wordle_suggestions(letters, keys), fn word ->
               Regex.scan(~r/[A-Z]/, word) != []
             end) == nil
    end

    test "suggested words must contain misplaced letters" do
      letters = %{1 => "", 2 => "", 3 => "", 4 => "a", 5 => ""}

      keys = %{
        "a" => :correct,
        "d" => :incorrect,
        "e" => :incorrect,
        "m" => :incorrect,
        "r" => :misplaced
      }

      assert Enum.find(
               Werds.wordle_suggestions(letters, keys),
               &Regex.match?(~r/^[^r]*$/, &1)
             ) == nil
    end

    test "suggested words must have letters we know in the right place" do
      letters = %{1 => "", 2 => "", 3 => "", 4 => "a", 5 => ""}

      keys = %{
        "a" => :correct,
        "d" => :incorrect,
        "e" => :incorrect,
        "m" => :incorrect,
        "r" => :misplaced
      }

      assert Enum.find(Werds.wordle_suggestions(letters, keys), &Regex.match?(~r/^...[^a].$/, &1)) ==
               nil
    end
  end
end
