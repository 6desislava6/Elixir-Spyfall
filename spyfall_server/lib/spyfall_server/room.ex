defmodule SpyfallServer.Room do
  use GenServer
  alias SpyfallServer.Room

  def broadcast(message) do
    GenServer.call(__MODULE__, {:broadcast, message})
  end

  def broadcast(message, users) do
    GenServer.call(__MODULE__, {:broadcast, message, users})
  end

  def start_link([room_name, node_name]) do
    GenServer.start_link(__MODULE__,  [room_name, node_name], [])
  end

  def start_game() do
    Room.broadcast()
  end

  def init([room_name, node_name]) do
    Node.monitor(node_name, true)
    {:ok, %{:owner => node_name, :users => [node_name], :room_name => room_name, :pid => self()}}
  end

  def handle_cast({:ask_player, from_player, to_player, question}, %{:users => users}=state) do
    broadcast_users(users, "#{from_player} asks #{to_player}: #{question}")
    # Node.spawn(to_player, GenServer, :cast, [SpyfallPlayer.Server, :answer])
    {:noreply, state}
  end

  def handle_call({:join_room, node_name}, _from, state) do
    Node.monitor(node_name, true)
    users = case Enum.member?(Map.get(state, :users), node_name) do
      true -> Map.get(state, :users)
      false -> Map.get(state, :users) ++ [node_name]
    end
    {:reply, :ok, Map.put(state, :users, users)}
  end

  def handle_call({:broadcast, message}, _from, %{:users => users}=state) do
    broadcast_users(users, message)
    {:reply, {:ok, "Broadcast to all..."}, state}
  end

  def handle_call({:broadcast, message, users}, _, state) do
    broadcast_users(users, message)
    {:reply, {:ok, "Broadcast to all..."}, state}
  end

  def handle_info({:nodedown, node_name}, %{:users => users, :room_name => room_name}=state) do
    state = Map.put(state, :users, List.delete(users, node_name))
    broadcast_users(state.users, "#{node_name} has disconnected")
    case length(state.users) do
      0 -> {:stop, :shutdown, state}
      _ -> {:noreply, state}
    end
  end

  def terminate(reason, state) do
    GenServer.cast({:global, :spyfall_server}, {:delete_room, state.room_name})
    :ok
  end

  def handle_info(msg, state) do
    IO.puts msg
    IO.puts "Unknown message."
    {:noreply, state}
  end

  ### Utilities ###
  defp broadcast_users(users, message) do
    users |> Enum.each(fn user ->
      Node.spawn(user, GenServer, :cast, [SpyfallPlayer.Server, {:broadcast, message}])
    end)
  end
end
