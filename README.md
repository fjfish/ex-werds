# Werdz

Elixir adaptation of the unfinished [Werds Gem](https://github.com/fjfish/werds). It takes a word and a match pattern. 

This is then used to find words that contain the letters of the word and match the pattern given. It was created in frustration when crossword games on my phone were charging very silly money for hints.

Plans include creating a word puzzle solver website, with this implementation as the first iteration.

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
