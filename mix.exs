defmodule RaSStaggregator.Mixfile do
  use Mix.Project

  defp description do
    "Feed aggregator for Elixir."
  end

  def project do
    [app: :rasstaggregator,
     version: "1.0.0-beta2",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     source_url: "https://github.com/slashrsm/rasstaggregator",
     description: description(),
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
      {:calendar, "~> 0.17"},
      {:dialyze, only: [:dev, :test]},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:inch_ex, only: :docs},
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
