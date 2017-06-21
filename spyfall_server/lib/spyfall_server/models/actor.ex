defmodule SpyfallServer.Actor do
  use Ecto.Schema

  schema "actors" do
    field :name, :string
	belongs_to :locations, SpyfallServer.Location, foreign_key: :location_id
  end
end

