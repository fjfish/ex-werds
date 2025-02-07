defmodule Werds do
  @moduledoc """
  A module to generate valid word variants from a base word.
  """

  # Load the dictionary into a MapSet for quick lookup
  @dictionary Path.join(:code.priv_dir(:werds), "/data/dictionary")
              |> File.read!()
              |> String.downcase()
              |> String.split("\n", trim: true)

  @elipsis "…"

  #  @doc """
  #  Generates all valid word variants from the given base word.
  #  """
  #  def generate_variants(base_word) do
  #    base_word
  #    |> String.downcase()
  #    |> String.graphemes()
  #    |> permutations()
  #    |> Enum.uniq()
  #    |> Enum.filter(&MapSet.member?(@dictionary, &1))
  #  end

  def words(match_pattern, source) do
    {:ok, search_pattern} =
      match_pattern
      |> String.downcase()
      |> String.replace(@elipsis, "...", global: true)
      |> String.replace(~r/[[:space:]]/, "", global: true)
      |> search_string(source)
      |> Regex.compile()

    mask = make_mask(source)

    Enum.reduce(@dictionary, [], fn str, list ->
      perform_match(Regex.match?(search_pattern, str), mask, str, list)
    end)
  end

  @doc """
  This takes a string mask like "...x.." and creates a string that can be turned into
  a regex for searching:

  Say the word is "banana" and we want to see words that will match a pattern like "..ana", as in each . would match the unused characters from our source word. You would need something like /[ban][ban]ana/ - this method generates it.

  """
  def make_mask(base_word, string) do
  end

  defp perform_match(true, str, list, mask) do
    if apply_mask(str, mask) do
      [str | list]
    else
      list
    end
  end

  defp perform_match(false, _, list, _) do
    list
  end

  defp apply_mask(string, mask) do
    string
    # Split the string into individual characters
    |> String.graphemes()
    |> Enum.reduce_while(%{}, fn char, acc ->
      # Increment the count for the character
      updated_count = Map.get(acc, char, 0) + 1

      if updated_count > Map.get(mask, char, 0) do
        # Stop and return false if the count exceeds the mask limit
        {:halt, false}
      else
        # Continue with the updated counts
        {:cont, Map.put(acc, char, updated_count)}
      end
    end)
    |> case do
      # Return false if the reduction halted early
      false -> false
      # Return true if the reduction completed successfully
      _ -> true
    end
  end

  def search_string(match_pattern, source) do
    # Remove dots from match_pattern
    matched_letters = String.replace(match_pattern, ".", "")
    # Duplicate source (strings are immutable in Elixir)
    unmatched_letters = source

    unmatched_letters =
      if String.length(matched_letters) > 0 do
        # Remove each matched letter from unmatched_letters (only the first occurrence)
        Enum.reduce(String.graphemes(matched_letters), unmatched_letters, fn letter, acc ->
          # Replace only the first occurrence
          String.replace(acc, letter, "", global: false)
        end)
      else
        # If no matched letters, keep the original
        unmatched_letters
      end

    # Replace dots in match_pattern with the unmatched letters in a regex-like format
    String.replace(match_pattern, ".", "[#{unmatched_letters}]")
  end
end
