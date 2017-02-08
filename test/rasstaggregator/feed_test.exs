defmodule RaSStaggregator.FeedTest do
  use ExUnit.Case
  alias RaSStaggregator.Feed
  doctest RaSStaggregator.Feed

  test ".new creates new feed struct and generates id" do
    feed = RaSStaggregator.Feed.new "http://example.com/feed", "My example feed"
    assert feed.name == "My example feed"
    assert feed.url == "http://example.com/feed"
    assert feed.id == :f12192

    feed = RaSStaggregator.Feed.new "http://example.com/another_feed"
    refute feed.name
    assert feed.url == "http://example.com/another_feed"
    assert feed.id == :ffc413
  end

  # TODO test parsing (need to create mock for http client)

end
