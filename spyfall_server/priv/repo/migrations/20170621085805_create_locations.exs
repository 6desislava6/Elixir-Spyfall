defmodule SpyfallServer.Migrations.AddLocationsTable do
  use Ecto.Migration

  def change do
    create table(:locations) do
      add :name, :string, size: 60
    end
  end
end