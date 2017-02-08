defmodule RaSStaggregator do
  @moduledoc """
  The RSS aggregator for Elixir.

  The RaSStaggregator will read the list of feeds from the configuration value:

      config :rasstaggregator, feeds: [
        "http://example.com/feed",
        "http://example.com/another_feed",
        "http://example.com/yet_another_feed",
      ]

  It is also possible to add a feed programatically:

      feed = RaSStaggregator.Feed.new "http://example.com/feed"
      RaSStaggregator.add_feed(feed)

  RaSStaggregator will start a parser for each feed and periodically check them
  and store them into ETS. It is easy to get the list of feed entries from it:

      feed = RaSStaggregator.Feed.new "http://example.com/feed"
      entries = RaSStaggregator.Cache.find(feed)
  """

  use Application

  @doc """
    RaSStaggregator application start function.
  """
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # See if any feeds are defined in configuration and start their parsers.
    children = Application.get_env(:rasstaggregator, :feeds, [])
    |> Enum.map(&(RaSStaggregator.Feed.new(&1)))
    |> Enum.map(&(worker(RaSStaggregator.Feed, [&1], [id: &1.id])))

    children = [worker(RaSStaggregator.Cache, [], [id: "cache"]) | children]

    opts = [strategy: :one_for_one, name: RaSStaggregator.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @doc """
  Adds a feed to the RaSStaggregator app.

  ## Parameters

  - `feed` - A feed struct.

  ## Example

      iex> feed = RaSStaggregator.Feed.new "http://example.com/feed"
      %RaSStaggregator.Feed{id: :f12192, name: nil, url: "http://example.com/feed"}
      iex> {:ok, pid} = RaSStaggregator.add_feed feed
      iex> is_pid(pid)
      true

  """
  @spec add_feed(RaSStaggregator.Feed.t) :: Supervisor.on_start_child
  def add_feed(feed) do
    Supervisor.start_child(RaSStaggregator.Supervisor, Supervisor.Spec.worker(RaSStaggregator.Feed, [feed], [id: feed.id]))
  end

end
