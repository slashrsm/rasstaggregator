defmodule RaSStaggregator.Cache do
  use GenServer

  @doc """
  Saves feed entries into ETS.

  ## Parameters

  - `feed` - A feed struct.
  - `entries` - A list of feed entries.

  ## Examples

      iex> feed = %RaSStaggregator.Feed{id: :example_feed_1, url: "http://example.com/some_feed"}
      iex> entries = []
      []
      iex> RaSStaggregator.Cache.save feed.id, entries
      true

  """
  @spec save(atom, list(any)) :: true
  def save(feed_id, entries) do
    :ets.insert(__MODULE__, {feed_id, entries})
  end


  @doc """
  Gets feed entries from the ETS table.

  ## Parameters

  - `feed` - A feed struct.

  ## Examples

      iex> feed = %RaSStaggregator.Feed{id: :example_feed_2, url: "http://example.com/some_feed"}
      iex> RaSStaggregator.Cache.find feed.id
      nil
      iex> RaSStaggregator.Cache.save feed.id, []
      true
      iex> RaSStaggregator.Cache.find feed.id
      []
      iex> RaSStaggregator.Cache.find :non_existing
      nil

  """
  @spec find(atom) :: list(any) | nil
  def find(feed_id) do
    case :ets.lookup(__MODULE__, feed_id) do
      [{_id, value}] -> value
      [] -> nil
    end
  end

  @doc """
  Removes all entries from the ETS table.

  ## Examples

      iex> feed = %RaSStaggregator.Feed{id: :example_feed_3, url: "http://example.com/some_feed"}
      iex> RaSStaggregator.Cache.save feed.id, []
      true
      iex> RaSStaggregator.Cache.find feed.id
      []
      iex> RaSStaggregator.Cache.clear
      true
      iex> RaSStaggregator.Cache.find feed.id
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
