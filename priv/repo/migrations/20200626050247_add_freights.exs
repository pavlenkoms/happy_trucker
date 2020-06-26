defmodule HappyTrucker.Repo.Migrations.AddFreights do
  use Ecto.Migration

  def change do
    create table(:freights) do
      add(:lat, :float, null: false)
      add(:long, :float, null: false)
      add(:status, :string, null: false)
      add(:driver_id, references(:users), null: true)
    end
  end
end
