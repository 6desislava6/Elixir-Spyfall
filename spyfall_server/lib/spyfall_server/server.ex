defmodule SpyfallServer.Server do
  use GenServer
  alias SpyfallServer.Room

  ### Api ###
  def get_all_rooms do
    GenServer.call({:global, :spyfall_server}, :get_all_rooms)
  end

  def get_state() do
    :sys.get_state({:global, :spyfall_server})
  end

  def get_room_state(room_name) do
    GenServer.call({:global, :spyfall_server}, {:get_room_state, room_name})
  end

  def broadcast_to_room(room_name, message) do
    GenServer.call({:global, :spyfall_server}, {:broadcast_to_room, room_name, message})
  end

  ### Calbacks ###
  def start_link do
    GenServer.start_link(__MODULE__, [], name: {:global, :spyfall_server})
  end

  def init(_) do
    {:ok, %{:ets_table => :ets.new(:spyfall_games, [:set, :private])}}
  end

  def handle_call(:get_all_rooms, _, state) do
    # TODO - see how to match all
    {:reply, :ets.lookup(state.ets_table, {}) , state}
  end

  def handle_call({:get_room_state, room_name}, _from,  %{ets_table: table}=state) do
    room_state = case :ets.lookup(table, room_name) do
      [{room_name, pid}] -> :sys.get_state(pid)
      [] -> IO.puts "No such room"
    end
    {:reply, room_state, state}
  end

  def handle_call({:broadcast_to_room, room_name, message}, _from,  %{ets_table: table}=state) do
    room_state = case :ets.lookup(table, room_name) do
      [{room_name, pid}] -> GenServer.call(pid, {:broadcast, message})
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
        {:ok, "Joined #{room_name} room.", pid}
      [] -> {:error, "Room doesn't exist."}
    end
    {:reply, result, state}
  end

  def handle_cast({:delete_room, room_name}, state) do
    :ets.delete(state.ets_table, room_name)
    {:noreply, state}
  end

  def handle_info({:DOWN, _ref, :process, _pid, _status}, state) do
    {:noreply, state}
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
        room_pid = create_room(node_name, room_name)
        :ets.insert(table, {room_name, room_pid})
        {{:ok, "Room created", room_pid}, state}
    end
  end

  defp add_room(false, _, _, state) do
    {{:error, "User is not connected."}, state}
  end

  defp create_room(node_name, room_name) do
    {:ok, room_pid} = GenServer.start(Room, [room_name, node_name])
    Process.monitor(room_pid)
    room_pid
  end

  def terminate(reason, state) do
    # TODO - да се мине по :ets и да се убият всички стаи
    :ok
  end
end