defmodule RoomTester do
  use ExUnit.Case, async: true
  alias SpyfallServer.Resourcer

  setup do
    Node.start(:test_node, :shortnames, 15000)

    :ok
  end

  test "join a room" do
    {:ok, room_pid} = GenServer.start(SpyfallServer.Room, ["testroom", node()])
    assert :ok == GenServer.call(room_pid, {:join_room, :"test_node@desi-beli"})

    %{guessed_players: [], owner: :"test_node@desi-beli", ready_players: [], room_name: "testroom", spy: nil, users: [:"test_node@desi-beli"], pid: _pid} = :sys.get_state(room_pid)
    assert _pid == room_pid
  end


end