defmodule RaSStaggregator.Mixfile do
  use Mix.Project

  @description """
    An Elixir feed aggregator.
  """

  def project do
    [app: :rasstaggregator,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     source_url: "https://github.com/slashrsm/rasstaggregator",
     description: "Feed aggregator for Elixir.",
     package: package(),
     deps: deps()]
  end

  def application do
    [
      extra_applications: [:logger, :httpoison],
      mod: {RaSStaggregator, []}
    ]
  end

  defp deps do
    [
      {:feeder_ex, "~> 1.0"}, 
      {:httpoison, "~> 0.11.0"}, 
      #{:timex, "~> 3.0"},
      {:dialyze, only: [:dev, :test]}
    ]
  end

  defp package do
    [ 
      files: ["lib", "mix.exs", "README.md"],
      maintainers: ["Janez Urevc"],
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/slashrsm/rasstaggregator"}
    ]
  end
end
