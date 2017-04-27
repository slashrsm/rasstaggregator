defmodule RaSStaggregator do
  @moduledoc """
  The RSS aggregator for Elixir.

  The RaSStaggregator will read the list of feeds from the configuration value:

      config :rasstaggregator, feeds: [
        %RaSStaggregator.Feed{id: :example_feed, url: "http://example.com/feed"},
        %RaSStaggregator.Feed{id: :another_feed, url: "http://example.com/another_feed"},
        %RaSStaggregator.Feed{id: :yet_another_feed, url: "http://example.com/yet_another_feed"},
      ]

  It is also possible to add a feed programatically:

      RaSStaggregator.add_feed(id, url)

  RaSStaggregator will start a parser for each feed and periodically check them
  and store them into ETS. It is easy to get the list of feed entries from it:

      feed = %RaSStaggregator.Feed{:id :example_feed, url: "http://example.com/feed"}
      entries = RaSStaggregator.Cache.find(feed.id)
  """

  use Application

  @doc """
    RaSStaggregator application start function.
  """
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # See if any feeds are defined in configuration and start their parsers.
    children = Application.get_env(:rasstaggregator, :feeds, [])
    |> Enum.map(&(worker(RaSStaggregator.Feed, [&1], [id: &1.id])))

    children = [worker(RaSStaggregator.Cache, [], [id: "cache"]) | children]

    opts = [strategy: :one_for_one, name: RaSStaggregator.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @doc """
  Adds a feed to the RaSStaggregator app.

  ## Parameters

  - `id` - Feed identifier.
  - `url` - Feed url.

  ## Examples

      iex> {:ok, pid} = RaSStaggregator.add_feed :example_feed, "http://example.com/feed"
      iex> is_pid(pid)
      true

  """
  @spec add_feed(atom, String.t) :: Supervisor.on_start_child
  def add_feed(id, url) do
    feed = %RaSStaggregator.Feed{id: id, url: url}
    Supervisor.start_child(RaSStaggregator.Supervisor, Supervisor.Spec.worker(RaSStaggregator.Feed, [feed], [id: feed.id]))
  end

  @doc """
  Returns the aggregator timeline consisting of the given feeds in a descending
  order.

  ## Parameters

  - `feeds` - List feed IDs to be includded in the timeline.

  ## Examples

  iex> RaSStaggregator.Cache.save(:first, [%FeederEx.Entry{title: "Example post 1", updated: "Thu, 27 Apr 2017 10:00:00 +0200"}])
  iex> RaSStaggregator.Cache.save(:second, [%FeederEx.Entry{title: "Example post 2", updated: "Thu, 27 Apr 2017 12:00:00 +0200"}])
  iex> RaSStaggregator.get_timeline [:first, :second]
  [%FeederEx.Entry{author: nil, duration: nil, enclosure: nil, id: nil,
    image: nil, link: nil, subtitle: nil, summary: nil, title: "Example post 2",
    updated: "Thu, 27 Apr 2017 12:00:00 +0200"},
   %FeederEx.Entry{author: nil, duration: nil, enclosure: nil, id: nil,
    image: nil, link: nil, subtitle: nil, summary: nil, title: "Example post 1",
    updated: "Thu, 27 Apr 2017 10:00:00 +0200"}]
  iex> RaSStaggregator.get_timeline [:second]
  [%FeederEx.Entry{author: nil, duration: nil, enclosure: nil, id: nil,
    image: nil, link: nil, subtitle: nil, summary: nil, title: "Example post 2",
    updated: "Thu, 27 Apr 2017 12:00:00 +0200"}]
  iex> RaSStaggregator.get_timeline [:first]
  [%FeederEx.Entry{author: nil, duration: nil, enclosure: nil, id: nil,
    image: nil, link: nil, subtitle: nil, summary: nil, title: "Example post 1",
    updated: "Thu, 27 Apr 2017 10:00:00 +0200"}]

  """
  @spec get_timeline([atom]) :: [%FeederEx.Entry{}]
  def get_timeline(feeds) do
    timeline = do_get_timeline(feeds, [])
      |> Enum.sort(&RaSStaggregator.Feed.compare_datetimes/2)

    timeline
  end

  defp do_get_timeline([], entries) do
    entries
  end

  @spec do_get_timeline([atom], [%FeederEx.Entry{}]) :: [%FeederEx.Entry{}]
  defp do_get_timeline([feed | rest], entries) do
    entries = entries ++ RaSStaggregator.Cache.find feed
    do_get_timeline rest, entries
  end

end
