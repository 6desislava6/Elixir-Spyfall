defmodule SpyfallServer.Room do
  use GenServer

  def start_link(node_name) do
    GenServer.start_link(__MODULE__,  node_name, [])
  end

  def init(node_name) do
    {:ok, %{:owner => node_name, :users => [node_name]}}
  end

  def handle_call({:join_room, node_name}, _from, state) do
  	IO.puts "Hererer"
  	{:reply, :ok, Map.put(state, :users, Map.get(state, :users) ++ [node_name])}
  end
end