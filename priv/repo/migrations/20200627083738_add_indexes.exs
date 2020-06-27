defmodule HappyTrucker.Repo.Migrations.AddIndexes do
  use Ecto.Migration

  def change do
    create(index(:users, :token))
    create(index(:freights, :status))
  end
end
