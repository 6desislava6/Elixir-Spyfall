defmodule SpyfallServer.RoomSupervisor do
  use Supervisor

  def add_room(room_pid) do
    Supervisor.start_child(RoomSupervisor.start_child, room_pid)
  end

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    supervise([], strategy: :one_for_one)
  end
end