defmodule SpyfallPlayer.Server do
  use GenServer

  ### Server ###
  def create_room(room_name) do
    case GenServer.call({:global, :spyfall_server}, {:create_room, room_name, node()}) do
      {:ok, msg, room_pid} ->
        IO.puts msg
        GenServer.call(__MODULE__, {:create_join_room, room_pid})
      {:error, msg} -> IO.puts msg
    end
  end

  def join_room(room_name) do
    case GenServer.call({:global, :spyfall_server}, {:join_room, room_name, node()}) do
      {:ok, msg, room_pid} ->
        IO.puts msg
        GenServer.call(__MODULE__, {:create_join_room, room_pid})
      {:error, msg} -> IO.puts msg
    end
  end

  def get_state() do
    :sys.get_state(__MODULE__)
  end

  def ask_player(to_player, question) do
    GenServer.cast(__MODULE__, {:ask_player, to_player, question})
  end

  ### Callbacks ###
  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    {:ok, %{}}
  end

  def handle_cast({:ask_player, to_player, question}, state) do
    GenServer.cast(state.room_pid, {:ask_player, node(), to_player, question})
    {:noreply, state}
  end

  def handle_call({:create_join_room, room_pid}, _from, state) do
    {:reply, :ok, Map.put(state, :room_pid, room_pid)}
  end

  def handle_cast({:broadcast, message}, state) do
    IO.puts message
    {:noreply, state}
  end

  def handle_call({:answer, question}, _from, state) do
    {:reply, Game.answer_question(question), state}
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