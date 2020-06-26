defmodule HappyTrucker.Repo do
  use Ecto.Repo,
    otp_app: :happy_trucker,
    adapter: Ecto.Adapters.Postgres
end
