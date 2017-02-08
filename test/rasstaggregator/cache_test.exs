defmodule RaSStaggregator.CacheTest do
  use ExUnit.Case
  alias RaSStaggregator.Cache

  setup do
    feed = RaSStaggregator.Feed.new "http://example.com/feed", "My example feed"
    Cache.save(feed, ["entry"])

    {:ok, feed: feed}
  end

  test ".save adds a feed to the ETS table" do
    info = :ets.info(Cache)
    assert info[:size] == 1
  end

  test ".find gets a feed out of the ETS table", %{feed: feed} do
    assert Cache.find(feed) == ["entry"]
  end

  test ".find returns nil if a feed is not in the ETS table" do
    unsaved_feed = RaSStaggregator.Feed.new "http://example.com/unsaved_feed"
    refute Cache.find(unsaved_feed)
  end

  test ".clear eliminates all objects from the ETS table", %{feed: feed} do
    Cache.clear
    refute Cache.find(feed)
  end
end