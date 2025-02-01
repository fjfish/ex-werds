defmodule Werdz do
  @moduledoc """
  Documentation for `Werdz`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Werdz.hello()
      :world

  """

  @moduledoc """
  A module to generate valid word variants from a base word.
  """

  # Load the dictionary into a MapSet for quick lookup
  @dictionary "../data/dictionary"
              |> File.read!()
              |> String.split("\n", trim: true)
              |> MapSet.new()

  @doc """
  Generates all valid word variants from the given base word.
  """
  def generate_variants(base_word) do
    base_word
    |> String.downcase()
    |> String.graphemes()
    |> permutations()
    |> Enum.uniq()
    |> Enum.filter(&MapSet.member?(@dictionary, &1))
  end

  # Generates all permutations of the given list of characters
  defp permutations([]), do: [[]]

  defp permutations(list) do
    for elem <- list, rest <- permutations(list -- [elem]), do: [elem | rest]
  end

  def hello do
    :world
  end
end
