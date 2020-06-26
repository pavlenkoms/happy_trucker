defmodule HappyTrucker.User do
  use Ecto.Schema

  schema "users" do
    field(:name, :string)
    field(:type, :string)
    field(:token, :string)
  end
end
