defmodule Game do
  alias SpyfallPlayer.Server

  def ask_player(to_player, question) do
    Server.ask_player(to_player, question)
  end

  def answer_player(to_player, answer) do
    Server.answer_player(to_player, answer)
  end

  def play do
    action_rooms()
    IO.gets ">>> Press enter when you are ready.\n"
    Server.player_ready(self())
    receive do
      :timesOn ->
        {location, role} = Server.begin_message()
        IO.puts "You are a: #{role} at: #{location}"
        main_game
    end
    guess_spy()
  end

  def action_rooms do
    case IO.gets ">>> Create or join a room, type 'join' or 'create' >>>\n" do
      "create\n" ->
        room = IO.gets ">>> Enter the room's name >>>\n"
        cycle_action_rooms(room |> Server.create_room)
      "join\n" ->
        room = IO.gets ">>> Enter the room's name >>>\n"
        cycle_action_rooms(room |> Server.join_room)
      _ ->
        IO.puts "Try again."
        action_rooms()
    end
  end

  def main_game do
    IO.puts "Waiting timesup"
    receive do
      :timesUp -> :ok
    after
      600 ->
        answers_questions()
        main_game()
    end
  end

  def answers_questions do
      case IO.gets ">>> 'ask' or 'ans' >>>\n" do
      "ans\n" ->
        user = IO.gets ">>> Whom do you answer? >>>\n"
        answer = IO.gets ">>> Your answer? >>>\n"
        Game.answer_player(user, answer)

      "ask\n" ->
        user = IO.gets ">>> Whom do you ask? >>>\n"
        question = IO.gets ">>> Your question? >>>\n"
        Game.ask_player(user, question)
      _ ->
        IO.puts "Try again"
        answers_questions()
    end
  end

  defp cycle_action_rooms(result) do
    case result do
      {:ok, msg} -> IO.puts msg
      {:error, msg} ->
        IO.puts msg
        action_rooms
    end
  end

  defp guess_spy do
    spy = IO.puts "Who is the spy? >>>\n"
    IO.puts "Waiting guessed"
    Server.guess_spy(spy)
    receive do
      {:all_guessed, ^spy} -> IO.puts "You guessed right."
      {:all_guessed, true_spy} -> IO.puts "You guessed wrong. The spy was #{true_spy}"
    end
  end

end