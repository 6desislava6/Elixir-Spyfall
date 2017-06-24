defmodule ServerTester do
  use ExUnit.Case, async: true
  alias SpyfallServer.Resourcer

  setup do
    Node.start(:test_node, :shortnames, 15000)
    Node.set_cookie(:"test_node@desi-beli", :spyfall)
    Node.connect(:"test_node@desi-beli")
    GenServer.call({:global, :spyfall_server}, {:create_room, "testroom", :test_node})
    :ok
  end

  test "create a room" do
    room_state = SpyfallServer.Server.get_room_state("testroom")
    room_pid = room_state.pid

    assert room_state == %{:owner => :"test_node@desi-beli", :users => [:"test_node@desi-beli"], :room_name => "testroom", :pid => room_pid,
    :ready_players => [], :guessed_players => [], :spy => nil}
    assert Process.alive?(room_pid) == true
  end

  test "join an existing room" do
    {:ok, msg, room_pid} = GenServer.call({:global, :spyfall_server}, {:join_room, "testroom", :test_node})
    assert msg == "Joined testroom room."
  end

  test "join not existing room" do
    {:error, msg} = GenServer.call({:global, :spyfall_server}, {:join_room, "baba", :test_node})
    assert msg == "Room doesn't exist."
  end

  test "get_room_state on a non-existing room" do
    assert {:error, "No such room"} == GenServer.call({:global, :spyfall_server}, {:get_room_state, "baba"})
  end
end