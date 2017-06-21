defmodule SpyfallServer.Location do
  use Ecto.Schema

  schema "locations" do
    field :name, :string
  end
end