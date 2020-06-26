defmodule HappyTruckerWeb.Authenticate do
  import Plug.Conn
  alias HappyTrucker.{Repo, User}

  def init(_opts), do: nil

  def call(conn, _opts) do
    user =
      case conn |> get_req_header("authorization") do
        [token] -> User |> Repo.get_by(token: token)
        _ -> nil
      end

    case user do
      nil ->
        conn
        |> send_resp(:unauthorized, "unauthorized")
        |> Plug.Conn.halt()

      %User{} = user ->
        conn |> assign(:current_user, user)
    end
  end
end
