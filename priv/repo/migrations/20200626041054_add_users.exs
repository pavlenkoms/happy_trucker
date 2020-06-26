defmodule HappyTrucker.Repo.Migrations.AddUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add(:name, :string, null: false)
      add(:type, :string, null: false)
      add(:token, :string, null: false)
    end
  end
end
