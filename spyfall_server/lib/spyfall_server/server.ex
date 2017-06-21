defmodule SpyfallServer.Server do
  use GenServer

  ### API ###
  def connect_player() do
    GenServer.call(__MODULE__, {:connect_player, })
  end

  ### Server ###
  def start_link do
    GenServer.start_link(__MODULE__, [], name: {:global, :spyfall_server})
  end

  def init(_) do
    {:ok, %{}}
  end

  def handle_call({:create_room, room_name}, _from, state) do
    GenServer.call(_from, {:room, :ok})
  end

end