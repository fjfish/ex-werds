defmodule Werds do
  @moduledoc """
  A module to generate valid word variants from a base word.
  Will also find anagrams of a word.
  """

  @data_dir Path.join(:code.priv_dir(:werds), "/data")

  # Load the dictionary into a List for quick lookup
  @dictionary @data_dir
              |> Path.join("/dictionary")
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
    processed_match_pattern = preprocess_match_pattern(match_pattern)

    {:ok, search_pattern} = compile_search_pattern(source_word, processed_match_pattern, options)

    source_char_counts = get_char_counts(source_word)
    match_char_counts = get_char_counts(String.replace(processed_match_pattern, ".", ""))

    case validate_matcher(source_word, processed_match_pattern, source_char_counts, match_char_counts) do
      :ok ->
        filter_dictionary(search_pattern, source_char_counts)

      {:error, message} ->
        {:error, message}
    end
  end

  defp preprocess_match_pattern(match_pattern) do
    match_pattern |> String.replace(@ellipsis, "...")
  end

  defp compile_search_pattern(source_word, processed_match_pattern, options) do
    Regex.compile(make_mask(source_word, processed_match_pattern), options)
  end

  defp validate_matcher(source_word, processed_match_pattern, source_char_counts, match_char_counts) do
    cond do
      too_many_letters?(source_word, processed_match_pattern) ->
        {:error, "Matcher has too many letters"}

      extra_letters?(source_char_counts, match_char_counts) ->
        {:error, "Source word does not have letters '#{extra_letters(source_char_counts, match_char_counts)}'"}

      overused_letters?(source_char_counts, match_char_counts) ->
        {:error, "Matcher uses source letters too many times"}

      true ->
        :ok
    end
  end

  defp too_many_letters?(source_word, processed_match_pattern) do
    String.length(source_word) < String.length(processed_match_pattern)
  end

  defp extra_letters?(source_char_counts, match_char_counts) do
    extra_letters(source_char_counts, match_char_counts) != []
  end

  defp extra_letters(source_char_counts, match_char_counts) do
    Map.keys(match_char_counts) -- Map.keys(source_char_counts)
  end

  defp overused_letters?(source_char_counts, match_char_counts) do
    Enum.any?(match_char_counts, fn {k, v} -> v > source_char_counts[k] end)
  end

  defp filter_dictionary(search_pattern, source_char_counts) do
    @dictionary
    |> Enum.filter(&(Regex.match?(search_pattern, &1) && check_word(get_char_counts(&1), source_char_counts)))
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
  @spec check_word(map(), map()) :: boolean()
  def check_word(word_char_counts, source_char_counts) do

    Enum.reduce(Map.keys(word_char_counts), true, fn char, acc ->
      acc and source_char_counts[char] >= word_char_counts[char]
    end)
  end

  @doc """
  Get anagrams
  """
  @spec anagrams(String.t()) :: [String.t()]
  def anagrams(word) do
    source_word = preprocess_word(word)
    match_pattern = build_match_pattern(source_word)
    search_pattern = compile_search_pattern!(source_word, match_pattern)
    source_char_counts = get_char_counts(source_word)

    filter_anagrams(search_pattern, source_char_counts)
  end

  defp preprocess_word(word) do
    word |> String.replace(~r/[[:space:]]/, "")
  end

  defp build_match_pattern(source_word) do
    source_word |> String.replace(~r/./, ".")
  end

  defp compile_search_pattern!(source_word, match_pattern) do
    Regex.compile!(make_mask(source_word, match_pattern), [:caseless])
  end

  defp filter_anagrams(search_pattern, source_char_counts) do
    @dictionary
    |> Enum.filter(&(Regex.match?(search_pattern, &1) && check_word(get_char_counts(&1), source_char_counts)))
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
