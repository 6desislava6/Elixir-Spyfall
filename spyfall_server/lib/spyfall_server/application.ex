defmodule SpyfallServer.Application do

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
       supervisor(SpyfallServer.Repo, []),
       worker(SpyfallServer.Server, []),
    ]

    opts = [strategy: :one_for_all, name: SpyfallServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
