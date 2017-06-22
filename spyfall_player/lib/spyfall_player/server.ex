defmodule SpyfallPlayer.Server do
  use GenServer

  def create_room(room_name) do
    case GenServer.call({:global, :spyfall_server, node()}, {:create_room, room_name}) do
      {:ok, message} -> IO.puts message
      {:error, message} -> IO.puts message
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