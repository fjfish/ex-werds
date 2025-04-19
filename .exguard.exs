use ExGuard.Config

guard("unit-test", run_on_start: true)
|> command("mix test --color")
|> watch(~r{\.(erl|ex|exs|eex|xrl|yrl)\z}i)
|> ignore(~r{deps})
|> notification(:auto)

# guard "mix test" do
#  watch(~r{^lib/.*\.ex$})
#  watch(~r{^test/.*_test\.exs$})
#  watch(~r{^mix\.exs$})
# end
