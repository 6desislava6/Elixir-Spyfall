defmodule SpyfallServer.Migrations.AddActorsTable do
  use Ecto.Migration

  def change do
    create table(:actors) do
      add :name, :string, size: 60
      add :location_id, references(:locations)
    end
  end
end


