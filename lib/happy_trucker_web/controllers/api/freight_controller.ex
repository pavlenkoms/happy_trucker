defmodule HappyTruckerWeb.API.FreightController do
  use HappyTruckerWeb.API, :controller

  alias HappyTrucker.Freight.{Index, Create, Update, Get}

  plug :authorize_resource, ["manager"] when action in [:create]

  plug :authorize_resource, ["manager", "driver"] when action in [:show, :index]

  plug :authorize_resource, ["driver"] when action in [:update]

  def index(conn, params) do
    with {:ok, freights} <- conn |> make_ctx() |> Index.run(params) do
      conn
      |> put_status(:ok)
      |> render(:index, freights: freights)
    end
  end

  def show(conn, params) do
    with {:ok, freight} <- conn |> make_ctx() |> Get.run(params) do
      conn
      |> put_status(:ok)
      |> render(:show, freight: freight)
    end
  end

  def create(conn, params) do
    with {:ok, freight} <- conn |> make_ctx() |> Create.run(params) do
      conn
      |> put_status(:ok)
      |> render(:show, freight: freight)
    end
  end

  def update(conn, params) do
    with {:ok, freight} <- conn |> make_ctx() |> Update.run(params) do
      conn
      |> put_status(:ok)
      |> render(:show, freight: freight)
    end
  end

  defp authorize_resource(conn, types) do
    case conn.assigns[:current_user].type in types do
      false ->
        conn
        |> ErrorHelpers.send_error(:forbidden, "forbidden")
        |> Plug.Conn.halt()

      true ->
        conn
    end
  end

  defp make_ctx(conn) do
    HappyTrucker.Params.make_ctx(%{current_user: conn.assigns[:current_user]})
  end
end
