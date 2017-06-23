defmodule SpyfallPlayer do
  @moduledoc """
  Documentation for SpyfallPlayer.
  """

  @doc """
  Hello world.

  ## Examples

      iex> SpyfallPlayer.hello
      :world

  """
  def create_room do
    IO.puts "Pick a name for your room: "
    SpyfallPlayer.Server
  end
end
