defmodule SpyfallPlayer.Application do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      # Starts a worker by calling: SpyfallPlayer.Worker.start_link(arg1, arg2, arg3)
      # worker(SpyfallPlayer.Worker, [arg1, arg2, arg3]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    connect(Application.get_env(:spyfall_player, :name))

    opts = [strategy: :one_for_one, name: SpyfallPlayer.Supervisor]
    Supervisor.start_link(children, opts)

  end

  defp connect(server) do
    IO.puts "Connecting to #{server} from #{Node.self} ..."
    Node.set_cookie(Node.self, :spyfall)
    case Node.connect(server) do
      true -> :ok
      reason ->
        IO.puts "Could not connect to server, reason: #{reason}"
        System.halt(0)
    end
  end
end
