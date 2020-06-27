defmodule HappyTrucker.Repo.Migrations.AddFinishLocationToFreights do
  use Ecto.Migration

  def change do
    rename table(:freights), :lat, to: :start_lat
    rename table(:freights), :long, to: :start_long

    alter table(:freights) do
      add(:finish_lat, :float, null: false)
      add(:finish_long, :float, null: false)
    end
  end
end
