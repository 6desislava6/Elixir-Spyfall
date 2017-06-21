defmodule SpyfallServer.Server do
  use GenServer

  ### API ###

  ### Server ###
  def start_link do
    # Make it global...

    GenServer.start_link(__MODULE__, [], name: {:global, :spyfall_server})
  end

  def init(_) do
    {:ok, %{}}
  end

  def handle_call({:create_room, room_name}, _from, state) do
    IO.puts "In server"

    # Тук някаква проверка за _from
    {:reply, :ok, state}
  end
end