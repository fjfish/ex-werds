# Werds

Elixir adaptation of the unfinished [Werds Gem](https://github.com/fjfish/werds). It takes a word and a match pattern. 

This is then used to find words that contain the letters of the word and match the pattern given. It was created in frustration when crossword games on my phone were charging very silly money for hints.

Plans include creating a word puzzle solver website, with this implementation as the first iteration.

The initial version was for the games where you have a word like PREFECT and then have to find all the different word variants.

Some of these games lay the words out in a crossword-like structure, others just ask for the words ordered by size and alphabet.

It uses a word list that was derived from the excellent tool [Scowl](http://wordlist.aspell.net/) with the command `./mk-list english british american 70 --accents strip > dictionary` - which gives is a list of several thousand words with no accents.

Note that the word list has only been minimally cleaned up, be careful of folks who get offended easily.

## Development

Run guard with `mix guard` - this will keep the tests running as you change files. The test suite is small but complete for the scenarios we could find.

## Installation

```elixir
def deps do
  [
    {:werds, ">= 1.6.1"}
  ]
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/fjfish/ex-werds. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/fjfish/ex-werds/blob/master/CODE_OF_CONDUCT.md).

## License

The library is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Werds project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/fjfish/ex-werds/blob/master/CODE_OF_CONDUCT.md).

