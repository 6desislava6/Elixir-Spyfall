defmodule SpyfallServer.Application do

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
       supervisor(SpyfallServer.Repo, []),
       worker(SpyfallServer.Server, []),
       supervisor(SpyfallServer.RoomSupervisor, [])
    ]

    opts = [strategy: :one_for_one, name: SpyfallServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
