defmodule SpyfallServer.Server do
  use GenServer
  alias SpyfallServer.Room
  ### API ###
  def get_state() do
    :sys.get_state({:global, :spyfall_server})
  end

  def get_room_state(room_name) do
    GenServer.call({:global, :spyfall_server}, {:get_room_state, room_name})
  end

  ### Server ###

  def start_link do
    GenServer.start_link(__MODULE__, [], name: {:global, :spyfall_server})
  end

  def init(_) do
    {:ok, %{:ets_table => :ets.new(:spyfall_games, [:set, :private])}}
  end

  def handle_call({:get_room_state, room_name}, _from,  %{ets_table: table}=state) do
    room_state = case :ets.lookup(table, room_name) do
      [{room_name, pid}] -> :sys.get_state(pid)
    end
    {:reply, room_state, state}
  end

  def handle_call({:create_room, room_name, node_name}, _from, state) do
    {result, new_state} = add_room(Enum.member?(Node.list(), node_name), room_name, node_name, state)
    {:reply, result, new_state}
  end

  def handle_call({:join_room, room_name, node_name}, _from, %{ets_table: table}=state) do
    result = case :ets.lookup(table, room_name) do
      [{room_name, pid}] ->
        GenServer.call(pid, {:join_room, node_name})
        {:ok, "Joined #{room_name} room."}
      [] -> {:error, "Room doesn't exist."}
    end
    {:reply, result, state}
  end

  # catch-all clause
  def handle_info(msg, state) do
    IO.puts msg
    IO.puts "Unknown message."
    {:noreply, state}
  end

  ### Rooms functionality ###
  defp add_room(true, room_name, node_name, %{ets_table: table}=state) do
    case :ets.lookup(table, room_name) do
      [{room_name, pid}] -> {{:error, "Room already exists."}, state}
      [] ->
        room_pid = create_room(node_name)
        :ets.insert(table, {room_name, room_pid}) |> IO.puts
        {{:ok, "Room created"}, state}
    end
  end

  defp add_room(false, _, _, state) do
    {{:error, "User is not connected."}, state}
  end

  defp create_room(node_name) do
    {:ok, room_pid} = GenServer.start(Room, node_name)
    Process.monitor(room_pid)
    room_pid
  end
end