defmodule SpyfallServer.Resourcer do
  import Ecto.Query, only: [from: 2]
  alias SpyfallServer.Resourcer

  def get_locations do
    query = from location in SpyfallServer.Location,
      select: [location.id, location.name]
    query |> SpyfallServer.Repo.all
  end

  def get_actors do
    query = from actor in SpyfallServer.Actor,
      select: actor
    query |> SpyfallServer.Repo.all
  end

  def get_actors_for_location(location_id) do
    query = from actor in SpyfallServer.Actor,
      where: actor.location_id == ^location_id,
      select: actor.name
    query |> SpyfallServer.Repo.all
  end

  def delete_actors do
    from(a in SpyfallServer.Actor, select: a)
    |> SpyfallServer.Repo.all
    |> Enum.each(fn record -> SpyfallServer.Repo.delete(record) end)
  end

  def get_roles_location(size) do
    :random.seed(:erlang.now)
    locations = Resourcer.get_locations
    location_id = Enum.random(0..(length(locations) - 1))
    IO.puts location_id
    {Enum.at(locations, location_id), get_actors_for_location(location_id) |> Enum.take_random(size)}
  end
end

