defmodule HappyTrucker.Factory do
  use ExMachina.Ecto, repo: HappyTrucker.Repo

  def freight_factory do
    %HappyTrucker.Freight{
      start_lat: 1.0,
      start_long: 1.0,
      finish_lat: 3.0,
      finish_long: 3.0,
      status: "new"
    }
  end

  def user_factory do
    name = sequence(:user, &"user-#{&1}")

    %HappyTrucker.User{
      name: name,
      token: name,
      type: "manager"
    }
  end
end
