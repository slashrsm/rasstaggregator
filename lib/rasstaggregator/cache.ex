defmodule RaSStaggregator.Cache do
  use GenServer

  @doc """
  Saves feed entries into ETS.

  ## Parameters

  - `feed` - A feed struct.
  - `entries` - A list of feed entries.

  ## Examples

      iex> feed = RaSStaggregator.Feed.new "http://example.com/feed"
      %RaSStaggregator.Feed{id: :f12192, name: nil, url: "http://example.com/feed"}
      iex> entries = []
      []
      iex> RaSStaggregator.Cache.save feed, entries
      true

  """
  @spec save(RaSStaggregator.Feed.t, list(any)) :: true
  def save(feed, entries) do
    :ets.insert(__MODULE__, {feed.id, entries})
  end


  @doc """
  Gets feed entries from the ETS table.

  ## Parameters

  - `feed` - A feed struct.

  ## Examples

      iex> feed = RaSStaggregator.Feed.new "http://example.com/some_feed"
      %RaSStaggregator.Feed{id: :fc6698, name: nil, url: "http://example.com/some_feed"}
      iex> RaSStaggregator.Cache.find feed
      nil
      iex> RaSStaggregator.Cache.save feed, []
      true
      iex> RaSStaggregator.Cache.find feed
      []

  """
  @spec find(RaSStaggregator.Feed.t) :: list(any) | nil
  def find(feed) do
    case :ets.lookup(__MODULE__, feed.id) do
      [{_id, value}] -> value
      [] -> nil
    end
  end

  @doc """
  Removes all entries from the ETS table.

  ## Examples

      iex> feed = RaSStaggregator.Feed.new "http://example.com/some_feed"
      %RaSStaggregator.Feed{id: :fc6698, name: nil, url: "http://example.com/some_feed"}
      iex> RaSStaggregator.Cache.save feed, []
      true
      iex> RaSStaggregator.Cache.find feed
      []
      iex> RaSStaggregator.Cache.clear
      true
      iex> RaSStaggregator.Cache.find feed
      nil

  """
  @spec clear :: true
  def clear do
    :ets.delete_all_objects(__MODULE__)
  end

  ###
  # GenServer API
  ###

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    table = :ets.new(__MODULE__, [:named_table, :public])
    {:ok, table}
  end

end