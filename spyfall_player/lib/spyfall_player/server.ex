defmodule SpyfallPlayer.Server do
  use GenServer

  def create_room(room_name) do
    case GenServer.call({:global, :spyfall_server}, {:create_room, room_name}) do
      :ok -> IO.puts "Room created."
      :error -> IO.puts "Something went wrong."
    end
  end

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    {:ok, %{}}
  end

  def handle_call({:room, :ok}, _from, state) do
    IO.puts "New room created"
  end
end