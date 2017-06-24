defmodule SpyfallServer.Resourcer do
  import Ecto.Query, only: [from: 2]
  alias SpyfallServer.Resourcer

  def get_locations do
    query = from location in SpyfallServer.Location,
      select: [location.id, location.name]
    query |> SpyfallServer.Repo.all |> Enum.map(fn [_, loc] -> loc end)
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
    locations = Resourcer.get_locations
    {location_id, actors} = get_location_actors(locations, size)
    {Enum.at(locations, location_id), actors}
  end

  defp get_location_actors(locations, size) do
    location_id = Enum.random(0..(length(locations) - 1))
    actors = get_actors_for_location(location_id)
    case actors do
      [] -> get_location_actors(locations, size)
      _ -> {location_id, actors |> Stream.cycle |> Enum.take(size) |> Enum.take_random(size)}
    end
  end
end

