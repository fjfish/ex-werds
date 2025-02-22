defmodule Werds do
  @moduledoc """
  A module to generate valid word variants from a base word.
  """

  # Load the dictionary into a List for quick lookup
  @dictionary Path.join(:code.priv_dir(:werds), "/data/dictionary")
              |> File.read!()
              |> String.split("\n", trim: true)

  @ellipsis "…"

  @doc """
  Give us a list of words from the dictionary, using the letters from
  `source`, that conform to the match pattern. The match looks like
  a "normal" regex, but when we have a . it matches the unused letters
  from the source word

  The default search is caseless and will find acronyms and proper names,
    pass an empty options list to turn this behaviour off

  Options [:proper_names] and [:acronyms] will do the obvious thing

  The option [:standard] turns off caseless and will only find "proper" words
  """
  @spec words(String.t(), String.t(), [term()]) :: [String.t()] | {:error, String.t()}

  def words(source_word, match_pattern), do: words(source_word, match_pattern, [:caseless])
  def words(source_word, match_pattern, [:standard]), do: words(source_word, match_pattern, [])

  def words(source_word, match_pattern, [:proper_names]) do
    words = words(source_word, match_pattern, [:caseless])
    case words do
      {:error, message} -> {:error, message}
      _ -> words |> Enum.filter(&Regex.match?(~r"^[A-Z][a-z]", &1))
    end
  end

  def words(source_word, match_pattern, [:acronyms]) do
    words = words(source_word, match_pattern, [:caseless])
    case words do
      {:error, message} -> {:error, message}
      _ -> words |> Enum.filter(&Regex.match?(~r"^[A-Z]+", &1))
    end
  end

  def words(source_word, match_pattern, options) do
    processed_match_pattern = match_pattern |> String.replace(@ellipsis, "...")

    {:ok, search_pattern} =
      Regex.compile(make_mask(source_word, processed_match_pattern), options)

    source_char_counts = get_char_counts(source_word)
    match_char_counts = get_char_counts(String.replace(processed_match_pattern, ".", ""))

    extra_letters = Map.keys(match_char_counts) -- Map.keys(source_char_counts)

    used_too_many_times =
      Enum.filter(match_char_counts, fn {k, v} -> v > source_char_counts[k] end)

    cond do
      String.length(source_word) < String.length(processed_match_pattern) ->
        {:error, "Matcher has too many letters"}

      extra_letters != [] ->
        {:error, "Source word does not have letters '#{extra_letters}'"}

      used_too_many_times != [] ->
        {:error, "Matcher uses source letters too many times"}

      true ->
        @dictionary
        |> Enum.filter(&Regex.match?(search_pattern, &1))
        |> Enum.filter(&check_word(get_char_counts(&1), source_char_counts))
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
  @spec check_word(Map, Map) :: true | false
  def check_word(word_char_counts, source_char_counts) do
    Map.keys(word_char_counts)
    |> Enum.reduce(true, fn char, acc ->
      acc and source_char_counts[char] >= word_char_counts[char]
    end)
  end

  #  @doc """
  #  Utility function that returns a map with the characters in a word as keys,
  #  and the number of times each letter appears. Used to further refine
  #  the list of words after the first regex pass and other checking
  #  """
  #  @spec get_char_counts(String.t()) :: Map
  defp get_char_counts(word) do
    word
    |> String.downcase()
    |> String.graphemes()
    |> Enum.reduce(%{}, fn char, acc ->
      count = Map.get(acc, char, 0)
      Map.put(acc, char, count + 1)
    end)
  end
end
