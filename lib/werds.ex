defmodule Werds do
  @moduledoc """
  A module to generate valid word variants from a base word.
  """

  # Load the dictionary into a List for quick lookup
  @dictionary Path.join(:code.priv_dir(:werds), "/data/dictionary")
              |> File.read!()
              |> String.downcase()
              |> String.split("\n", trim: true)

  @ellipsis "…"

  @doc """
  Give us a list of words from the dictionary, using the letters from
  `source`, that conform to the match pattern. The match looks like
  a "normal" regex, but when we have a . it matches the unused letters
  from the source word
  """
  @spec words(String.t(), String.t()) :: [String.t()] | {:error, String.t()}
  def words(source_word, match_pattern) do
    {:ok, search_pattern} =
      Regex.compile(make_mask(source_word, match_pattern))

    source_char_counts = get_char_counts(source_word)
    match_char_counts = get_char_counts(String.replace(match_pattern, ".", ""))

    extra_letters = Map.keys(match_char_counts) -- Map.keys(source_char_counts)

    case extra_letters do
      [] ->
        Enum.reduce(@dictionary, [], fn str, list ->
          if Regex.match?(search_pattern, str) do
            [str | list]
          else
            list
          end
        end)
        |> Enum.reduce([], fn str, list ->
          if check_word(get_char_counts(str), source_char_counts) do
            [str | list]
          else
            list
          end
        end)

      _ ->
        {:error, "Source word does not have letters '#{extra_letters}'"}
    end
  end

  @doc """
  This takes a string mask like "...x.." and creates a string that can be turned into
  a regex for searching:

  Say the word is "banana" and we want to see words that will match a pattern like "..ana",
  as in each . would match the unused characters from our source word.
  You would need /\[ban]\[ban]ana/ - this method generates it.

  """
  @spec make_mask(String.t(), String.t()) :: String.t()
  def make_mask(source_word, match_string) do
    pre_processed_match =
      match_string
      |> String.replace(@ellipsis, "...")
      |> String.downcase()
      |> String.replace(~r/[[:space:]]/, "")

    used_chars =
      pre_processed_match
      |> String.replace(".", "")
      |> String.graphemes()

    adjusted_regex =
      Enum.reduce(used_chars, source_word, fn char, acc ->
        String.replace(acc, char, "", global: false)
      end)

    "^#{String.replace(pre_processed_match, ".", "[#{adjusted_regex}]")}$"
  end

  @doc """
  Check that the number of letters in the candidate word are less than or equal
    to the number of letters in the word we used as a source
  """
  @spec check_word(Map.t(), Map.t()) :: true | false
  def check_word(word_char_counts, source_char_counts) do
    Map.keys(word_char_counts)
    |> Enum.reduce(true, fn char, acc ->
      acc and Map.get(source_char_counts, char) >= Map.get(word_char_counts, char)
    end)
  end

  #  @doc """
  #  Utility function that returns a map with the characters in a word as keys,
  #  and the number of times each letter appears. Used to further refine
  #  the list of words after the first regex pass and other checking
  #  """
  #  @spec get_char_counts(String.t()) :: Map.t()
  defp get_char_counts(word) do
    Enum.reduce(String.graphemes(word), %{}, fn char, acc ->
      count = Map.get(acc, char, 0)
      Map.put(acc, char, count + 1)
    end)
  end
end
