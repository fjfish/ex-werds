# Werds

Elixir adaptation of the unfinished [Werds Gem](https://github.com/fjfish/werds). It takes a word and a match pattern. 

This is then used to find words that contain the letters of the word and match the pattern given. It was created in frustration when crossword games on my phone were charging very silly money for hints.

Plans include creating a word puzzle solver website, with this implementation as the first iteration.

The initial version was for the games where you have a word like PREFECT and then have to find all the different word variants.

Some of these games lay the words out in a crossword-like structure, others just ask for the words ordered by size and alphabet.

It uses a word list that was derived from the excellent tool [Scowl](http://wordlist.aspell.net/) with the command `./mk-list english british american 70 --accents strip > dictionary` - which gives is a list of several thousand words with no accents.

Note that the word list has not been cleaned up, be careful of folks who get offended easily.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `werds` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:werds, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/werds>.
