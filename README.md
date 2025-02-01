# Werdz

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `werdz` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:werdz, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/werdz>.

defmodule Werds do
@moduledoc """
A module to generate valid word variants from a base word.
"""

# Load the dictionary into a MapSet for quick lookup
@dictionary "path/to/dictionary.txt"
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
end