![](https://i.imgur.com/KqxckgE.png)
# RaSStaggregator

Feed aggregator for Elixir.

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
  "http://example.com/feed",
  "http://example.com/another_feed",
  "http://example.com/yet_another_feed",
]
```

It is also possible to add a feed programatically:

```elixir
feed = RaSStaggregator.Feed.new "http://example.com/feed"
RaSStaggregator.add_feed(feed)
```

RaSStaggregator will start a parser for each feed and periodically check them
and store them into ETS. It is easy to get the list of feed entries from it:

```elixir
feed = RaSStaggregator.Feed.new "http://example.com/feed"
entries = RaSStaggregator.Cache.find(feed)
```
