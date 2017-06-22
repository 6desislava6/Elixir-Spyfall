defmodule SpyfallServer.Server do
  use GenServer
  alias SpyfallServer.RoomSupervisor
  alias SpyfallServer.Room
  ### API ###

  ### Server ###
  def start_link do
    GenServer.start_link(__MODULE__, [], name: {:global, :spyfall_server})
  end

  def init(_) do
    {:ok, %{:ets_table => :ets.new(:spyfall_games, [:set, :private])}}
  end

  def handle_call({:create_room, room_name, node_name}, _from, state) do
    {result, new_state} = add_room(Enum.member?(Node.list(), node_name), room_name, state)
    {:reply, result, new_state}
  end

  # catch-all clause
  def handle_info(_, state) do
    IO.puts "unknown message"
    {:noreply, state}
  end

  ### Rooms functionality ###
  defp add_room(true, room_name, %{ets_table: table}=state) do
    case :ets.lookup(table, room_name) do
      {:ok, pid} -> {{:error, "Room already exists."}, state}
      :error ->
        room_pid = register_room
        :ets.insert(table, {room_name, room_pid}) |> IO.puts
        {{:ok, "Room created"}, state}
    end
  end

  defp add_room(false, _, state) do
    {{:error, "User is not connected."}, state}
  end

  defp register_room do
    {:ok, room_pid} = GenServer.start(Room, [])
    room_pid |> RoomSupervisor.add_room
    room_pid
  end
end