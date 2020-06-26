# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     HappyTrucker.Repo.insert!(%HappyTrucker.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias HappyTrucker.User

managers = for i <- 1..5 do
  %Channel{name: "manager_#{i}", token: "managers_token_#{i}", type: "manager"}
end

drivers = for i <- 1..10 do
  %Channel{name: "driver_#{i}", token: "drivers_token_#{i}", type: "driver"}
end


Enum.each(managers ++ drivers, fn user ->
  HappyTrucker.Repo.insert(user)
end)
