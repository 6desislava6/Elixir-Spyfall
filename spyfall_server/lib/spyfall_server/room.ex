defmodule SpyfallServer.Room do
  use GenServer
  alias SpyfallServer.Room

  ### Api ###
  def broadcast(message) do
    GenServer.call(__MODULE__, {:broadcast, message})
  end

  def broadcast(message, users) do
    GenServer.call(__MODULE__, {:broadcast, message, users})
  end

  ### Callbacks ###
  def start_link([room_name, node_name]) do
    GenServer.start_link(__MODULE__,  [room_name, node_name], [])
  end

  def start_game() do
    Room.broadcast()
  end

  def init([room_name, node_name]) do
    Node.monitor(node_name, true)
    {:ok, %{:owner => node_name, :users => [node_name], :room_name => room_name, :pid => self(),
    :ready_players => [], :guessed_players => [], :spy => nil}}
  end

  def handle_cast({:guess_spy, spy, player}, state) do
    guessed_players = state.guessed_players ++ [player]

    case length(guessed_players) == length(state.users) do
      true ->
        notify_users(state.users, {:all_guessed, state.spy})
        {:stop, :shutdown, state}
      false -> {:noreply, Map.put(state, :guessed_players, guessed_players)}
    end
  end

  def handle_cast({:player_ready, player, room_pid}, state) do
    broadcast_users(state.users, "#{player} is player_ready")
    ready_players = state.ready_players ++ [player]

    case length(ready_players) == length(state.users) do
      true ->
        set_timer(room_pid)
        {location, roles} = SpyfallServer.Resourcer.get_roles_location(length(state.users))
        {spy_id, roles} = assign_spy_role(roles)
        state = Map.put(state, :spy, Enum.at(state.users, spy_id))
        notify_users_individual(state.users, {:all_ready, location}, roles)
      false -> :ok
    end
    {:noreply, Map.put(state, :ready_players, ready_players)}
  end

  def handle_cast({:ask_player, from_player, to_player, question}, %{:users => users}=state) do
    broadcast_users(users, "#{from_player} asks #{to_player}: #{question}")
    {:noreply, state}
  end

  def handle_cast({:answer_player, from_player, to_player, answer}, %{:users => users}=state) do
    broadcast_users(users, "#{from_player} answers  #{to_player}: #{answer}")
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

  def handle_cast(:timesUp, state) do
    broadcast_users(state.users, "Time's up!")
    notify_users(state.users, :timesUp)
    {:noreply, state}
  end

  def handle_info(msg, state) do
    IO.puts msg
    IO.puts "Unknown message."
    {:noreply, state}
  end

  ### Utilities ###
  defp broadcast_users(users, message) do
    spawn_fn_users(users, GenServer, :cast, [SpyfallPlayer.Server, {:broadcast, message}])
  end

  defp notify_users(users, signal) do
    users |> Enum.each(fn user ->
      Node.spawn(user, GenServer, :cast, [SpyfallPlayer.Server, signal])
    end)
  end

  defp notify_users_individual(users, signal, roles) do
    Enum.with_index(users) |> Enum.each(fn {user, index} ->
      Node.spawn(user, GenServer, :cast, [SpyfallPlayer.Server, {signal, Enum.at(roles, index)}])
    end)
  end

  defp spawn_fn_users(users, mod, fun, args) do
    users |> Enum.each(fn user ->
      Node.spawn(user, mod, fun, args)
    end)
  end

  defp set_timer(room_pid) do
    :timer.apply_after(3000, GenServer, :cast, [room_pid, :timesUp])
  end

  defp assign_spy_role(roles) do
    spy_id = Enum.random(0..(length(roles) - 1))
    {spy_id, List.replace_at(roles, spy_id, "~the spy~")}
  end
end
