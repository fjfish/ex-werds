defmodule Werds.MixProject do
  use Mix.Project

  def project do
    [
      app: :werds,
      version: "1.0.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      description: "Find dictionary words that can be constructed from a given word",
      author: "Francis Fish",
      deps: deps(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: []
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE*"],
      maintainers: ["Francis Fish"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/fjfish/ex-werds"}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:ex_guard, ">= 1.6.1", only: :dev},
      # optional for linting
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:ex_unit_notifier, "~> 1.3", only: :test},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end
end
