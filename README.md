# ![](https://i.imgur.com/7IUuHes.png)

Feed aggregator for Elixir.


[![Build
Status](https://travis-ci.org/slashrsm/rasstaggregator.svg?branch=master)](https://travis-ci.org/slashrsm/rasstaggregator)
[![Deps Status](https://beta.hexfaktor.org/badge/all/github/slashrsm/rasstaggregator.svg)](https://beta.hexfaktor.org/github/slashrsm/rasstaggregator)
[![Inline docs](http://inch-ci.org/github/slashrsm/rasstaggregator.svg)](http://hexdocs.pm/rasstaggregator/)
[![Hex Version](http://img.shields.io/hexpm/v/rasstaggregator.svg?style=flat)](https://hex.pm/packages/rasstaggregator)
[![Coverage Status](https://coveralls.io/repos/github/slashrsm/rasstaggregator/badge.svg?branch=master)](https://coveralls.io/github/slashrsm/rasstaggregator?branch=master)

## Installation

First, add RaSStaggregator to your `mix.exs` dependencies:

```elixir
def deps do
  [{:rasstaggregator, "~> 1.0"}]
end
```

and run `$ mix deps.get`. Now, list the `:rasstaggregator` application as your
application dependency:

```elixir
def application do
  [applications: [:rasstaggregator]]
end
```

## Usage

The RaSStaggregator will read the list of feeds from the configuration value:

```elixir
config :rasstaggregator, feeds: [
  %RaSStaggregator.Feed{id: :example_feed, url: "http://example.com/feed"},
  %RaSStaggregator.Feed{id: :another_feed, url: "http://example.com/another_feed"},
  %RaSStaggregator.Feed{id: :yet_another_feed, url: "http://example.com/yet_another_feed"},
]
```

It is also possible to add a feed programatically:

```elixir
RaSStaggregator.add_feed :feed_id, "http://example.com/feed"
```

RaSStaggregator will start a parser for each feed and periodically check them
and store them into ETS. It is easy to get the list of feed entries from it:

```elixir
entries = RaSStaggregator.Cache.find(:feed_id)
```

or to get the post timeline consisting out of multiple feeds:

```elixir
timeline = RaSStaggregator.get_timeline([:feed_id_1, :feed_id_2, ...])
```
