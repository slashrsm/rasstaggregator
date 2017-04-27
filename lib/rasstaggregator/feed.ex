defmodule RaSStaggregator.Feed do
  @moduledoc """
  Represents a feed and works with it.
  """
  require Logger
  use GenServer

  defstruct id: nil,
    url: nil,
    timeout: 900

  @type t :: %RaSStaggregator.Feed{
    id: atom,
    url: String.t,
    timeout: integer,
  }

  @doc """
  Periodically parses a feed in an infinite loop.

  ## Parameters

  - `feed` - A feed struct.
  """
  @spec parse(RaSStaggregator.Feed.t) :: any
  def parse feed do
    case HTTPoison.get(feed.url) do
      {:ok, %HTTPoison.Response{body: body}} ->
        try do
          {:ok, parsed_feed, _} = FeederEx.parse(body)
          entries = parsed_feed.entries
            |> Enum.sort(&compare_datetimes/2)

          RaSStaggregator.Cache.save(feed.id, entries)
        catch
          _exception -> 
            Logger.error("Unable to parse feed #{feed.url}")
        end
      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("Unable to get feed #{feed.url}: " <> Atom.to_string(reason))
    end
  end

  @doc """
  Compares two feed entries and determines which one was published in an earlier
  point in time.

  Returns `false` if the first feed was published in an earlier point in time and
  `true` otherwise.

  ## Parameters

  - `first` - A first feed entry.
  - `second` - A second feed entry.

  ## Examples

      iex> first = %FeederEx.Entry{updated: "Thu, 27 Apr 2017 10:00:00 +0200"}
      iex> second = %FeederEx.Entry{updated: "Thu, 27 Apr 2017 11:00:00 +0200"}
      iex> RaSStaggregator.Feed.compare_datetimes first, second
      false
      iex> RaSStaggregator.Feed.compare_datetimes second, first
      true
      iex> RaSStaggregator.Feed.compare_datetimes first, first
      true

  """
  @spec compare_datetimes(FeederEx.Entry, FeederEx.Entry) :: true | false
  def compare_datetimes first, second do
    {:ok, first_parsed} = Calendar.DateTime.Parse.rfc822_utc first.updated
    {:ok, second_parsed} = Calendar.DateTime.Parse.rfc822_utc second.updated

    # TODO try to parse more different formates if RFC822 failed. Yes, it is
    # defined by the RSS standard, but feeds come with all sorts of different
    # things.

    case DateTime.compare(first_parsed, second_parsed) do
      :lt -> false
      _ -> true
    end
  end

  ###
  # GenServer API
  ###
  def start_link feed do
    GenServer.start_link(__MODULE__, feed)
  end

  def init(feed) do
    schedule_parse(1)
    {:ok, feed}
  end

  def handle_info(:parse, feed) do
    parse(feed)
    schedule_parse(feed.timeout)
    {:noreply, feed}
  end

  @spec schedule_parse(non_neg_integer) :: any
  defp schedule_parse timeout do
    Process.send_after(self(), :parse, timeout * 1000)
  end

end
