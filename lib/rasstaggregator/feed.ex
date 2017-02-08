defmodule RaSStaggregator.Feed do
  @moduledoc """
  Represents a feed and works with it.
  """
  #import DateTime, only: [from_iso8601: 1, to_unix: 1, to_unix: 2]
  require Logger

  defstruct id: nil,
            name: nil,
            url: nil

  @type t :: %RaSStaggregator.Feed{
    id: atom,
    name: String.t | nil,
    url: String.t,
  }

  @doc """
  Gets a feed struct.

  ## Parameters

  - `feed` - A feed struct.

  ## Example

      iex> RaSStaggregator.Feed.new "http://example.com/feed"
      %RaSStaggregator.Feed{id: :f12192, name: nil, url: "http://example.com/feed"}

      iex> RaSStaggregator.Feed.new "http://example.com/feed", "My nice feed"
      %RaSStaggregator.Feed{id: :f12192, name: "My nice feed", url: "http://example.com/feed"}
  """
  @spec new(String.t, String.t | nil) :: RaSStaggregator.Feed.t
  def new url, name \\ nil do
    id = :crypto.hash(:md5 , url)
    |> Base.encode16(case: :lower)
    |> String.slice(0..4)

    # TODO f
    %RaSStaggregator.Feed{id: String.to_atom("f" <> id), url: url, name: name}
  end

  @doc """
  Starts a new parser process for a given feed.

  ## Parameters

  - `feed` - A feed struct.
  """
  @spec start_link(RaSStaggregator.Feed.t) :: {:ok, pid}
  def start_link feed do
    pid = spawn(RaSStaggregator.Feed, :parse, [feed])
    {:ok, pid}
  end

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
          # TODO Use timex library to parse dates and sort
          #|> Enum.sort(&compare_datetimes/2)

          RaSStaggregator.Cache.save(feed, entries)
        catch
          _exception -> 
            Logger.error("Unable to parse feed #{feed.url}")
        end
      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("Unable to get feed #{feed.url}: " <> Atom.to_string(reason))
    end

    Process.sleep(300_000)
    parse feed
  end

  #def compare_datetimes first, second do
  #  {:ok, first_parsed, _offset} = from_iso8601(first)
  #  {:ok, second_parsed, _offset} = from_iso8601(second)

  #  to_unix(first_parsed) <= to_unix(second_parsed)
  #end
end
