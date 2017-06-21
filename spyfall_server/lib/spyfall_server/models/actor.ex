defmodule SpyfallServer.Actor do
  use Ecto.Schema

  schema "actors" do
    field :name, :string
    #has_one :locations, SpyfallServer.Location
	belongs_to :locations, SpyfallServer.Location, foreign_key: :location_id
  end
end