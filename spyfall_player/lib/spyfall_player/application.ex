defmodule SpyfallPlayer.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(SpyfallPlayer.Server, []),
      worker(SpyfallPlayer.Connector, []),
      supervisor(Task.Supervisor, [[name: SpyfallPlayer.TaskSupervisor]])
    ]
    opts = [strategy: :one_for_all, name: SpyfallPlayer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
