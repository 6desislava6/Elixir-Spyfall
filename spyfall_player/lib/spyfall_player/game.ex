defmodule Game do
  def ask_player(to_player, question) do
    SpyfallPlayer.Server.ask_player(to_player, question)
  end
end