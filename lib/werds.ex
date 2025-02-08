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
  @spec words(String.t(), String.t()) :: [String.t()]
  def words(source_word, match_pattern) do
    {:ok, search_pattern} =
      Regex.compile(make_mask(source_word, match_pattern))

    Enum.reduce(@dictionary, [], fn str, list ->
      if Regex.match?(search_pattern, str) do
        [str | list]
      else
        list
      end
    end)
  end

  @doc """
  This takes a string mask like "...x.." and creates a string that can be turned into
  a regex for searching:

  Say the word is "banana" and we want to see words that will match a pattern like "..ana",
  as in each . would match the unused characters from our source word.
  You would need /[ban][ban]ana/ - this method generates it.

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
end
