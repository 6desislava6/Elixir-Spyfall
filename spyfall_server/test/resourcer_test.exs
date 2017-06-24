defmodule ResourcerTester do
  use ExUnit.Case, async: true
  alias SpyfallServer.Resourcer

  test "gets roles for a location" do
    IO.inspect Resourcer.get_actors_for_location(1)
    assert Resourcer.get_actors_for_location(1) == ["first class passenger",
                                          "air marshall",
                                          "mechanic",
                                          "air hostess",
                                          "copilot",
                                          "captain",
                                          "economy class passenger"]
  end

  test "generates exactly n roles" do
    all = (Resourcer.get_locations |> length) - 1
    1..all |> Enum.each(fn size ->
      IO.puts size
      IO.inspect Resourcer.get_roles_location(size)
      {location, actors} = Resourcer.get_roles_location(size)

      assert length(actors) == size
    end)
  end

  test "gets correct locations" do
    assert is_list(Resourcer.get_locations) == true
  end

end