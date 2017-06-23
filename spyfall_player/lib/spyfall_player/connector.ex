defmodule SpyfallPlayer.Connector do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    connect
    {:ok, %{}}
  end

  def handle_info({:nodedown, server}, state) do
    main_server = Application.get_env(:spyfall_player, :name)

    IO.puts "Game stopped!"
    case server do
      ^main_server ->
        IO.puts "Server has disconnected."
        IO.puts "Trying to reconnect."
        connect
      _ -> nil
    end
    {:noreply, state}
  end

  def handle_info(msg, state) do
    IO.puts msg
  end

  defp connect do
    server = Application.get_env(:spyfall_player, :name)
    IO.puts "Connecting to #{server} from #{Node.self} ..."
    Node.set_cookie(Node.self, :spyfall)
    case Node.connect(server) do
      true ->
        Node.monitor(server, true)
        IO.puts "Connected."
      reason ->
        IO.puts "Could not connect to server, reason: #{reason}"
        IO.puts "Trying to reconnect."
        :timer.sleep(3000)
        connect
    end
  end
end