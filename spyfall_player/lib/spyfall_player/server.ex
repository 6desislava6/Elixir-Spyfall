defmodule SpyfallPlayer.Server do
  use GenServer

  def create_room(room_name) do
    GenServer.call({:global, :spyfall_server}, {:create_room, room_name, node()})
    |> handle_message
  end

  def join_room(room_name) do
    GenServer.call({:global, :spyfall_server}, {:join_room, room_name, node()})
    |> handle_message
  end

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    {:ok, %{}}
  end

  def handle_cast({:broadcast, message}, state) do
    IO.puts message
    {:noreply, state}
  end

  # catch-all clause
  def handle_info(msg, state) do
    IO.puts msg
    IO.puts "Unknown message."
    {:noreply, state}
  end

  defp handle_message(result) do
    case result do
      {_, message} -> IO.puts message
    end
  end
end