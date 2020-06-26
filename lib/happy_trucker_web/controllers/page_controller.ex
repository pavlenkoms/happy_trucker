defmodule HappyTruckerWeb.PageController do
  use HappyTruckerWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
