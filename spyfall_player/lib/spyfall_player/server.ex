defmodule SpyfallPlayer.Server do
  use GenServer

  ### Server ###
  def create_room(room_name) do
    case GenServer.call({:global, :spyfall_server}, {:create_room, room_name, node()}) do
      {:ok, msg, room_pid} ->
        GenServer.call(__MODULE__, {:create_join_room, room_pid})
        {:ok, msg}
      {:error, msg} -> {:error, msg}
    end
  end

  def join_room(room_name) do
    case GenServer.call({:global, :spyfall_server}, {:join_room, room_name, node()}) do
      {:ok, msg, room_pid} ->
        GenServer.call(__MODULE__, {:create_join_room, room_pid})
        {:ok, msg}
      {:error, msg} -> {:error, msg}
    end
  end

  def get_state do
    :sys.get_state(__MODULE__)
  end

  def ask_player(to_player, question) do
    GenServer.cast(__MODULE__, {:ask_player, to_player, question})
  end

  def answer_player(to_player, answer) do
    GenServer.cast(__MODULE__, {:answer_player, to_player, answer})
  end

  def player_ready(game_pid) do
    GenServer.cast(__MODULE__, {:player_ready, game_pid})
  end

  def guess_spy(spy) do
    GenServer.cast(__MODULE__, {:guess_spy, spy})
  end

  def begin_message do
    GenServer.call(__MODULE__, :begin_message)
  end

  ### Callbacks ###
  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    {:ok, %{}}
  end

  def handle_call(:begin_message, _, state) do
    {:reply, {state.location, state.role}, state}
  end

  def handle_cast({:all_guessed, spy}, state) do
    send(state.game_pid, {:all_guessed, spy})
    {:noreply, state}
  end

  def handle_cast({:guess_spy, spy}, state) do
    GenServer.cast(state.room_pid, {:guess_spy, spy, node()})
    {:noreply, state}
  end

  def handle_cast({{:all_ready, location}, role}, state) do
    send(state.game_pid, :timesOn)
    {:noreply, Map.put(state, :role, role) |> Map.put(:location, location) }
  end

  def handle_cast(:timesUp, state) do
    send(state.game_pid, :timesUp)
    {:noreply, state}
  end

  def handle_cast({:player_ready, game_pid}, state) do
    IO.inspect game_pid
    GenServer.cast(state.room_pid, {:player_ready, node(), state.room_pid})
    {:noreply, Map.put(state, :game_pid, game_pid)}
  end

  def handle_cast({:ask_player, to_player, question}, state) do
    GenServer.cast(state.room_pid, {:ask_player, node(), to_player, question})
    {:noreply, state}
  end

  def handle_cast({:answer_player, to_player, answer}, state) do
    GenServer.cast(state.room_pid, {:answer_player, node(), to_player, answer})
    {:noreply, state}
  end

  def handle_call({:create_join_room, room_pid}, _from, state) do
    {:reply, :ok, Map.put(state, :room_pid, room_pid)}
  end

  def handle_cast({:broadcast, message}, state) do
    IO.puts message
    {:noreply, state}
  end

  # catch-all clause
  def handle_info(msg, state) do
    IO.puts "Unknown message."
    {:noreply, state}
  end

  defp handle_message(result) do
    case result do
      {_, message} -> IO.puts message
    end
  end
end