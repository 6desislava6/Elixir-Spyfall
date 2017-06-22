defmodule SpyfallServer.RoomSupervisor do
  use Supervisor
  alias SpyfallServer.RoomSupervisor
  alias SpyfallServer.Room

  def add_room do
    {:ok, room_pid} = Supervisor.start_child(RoomSupervisor, worker(Room, []))
    room_pid
  end

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_), do: supervise([], [strategy: :one_for_one])
end