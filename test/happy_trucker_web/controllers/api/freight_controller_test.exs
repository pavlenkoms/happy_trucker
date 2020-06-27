defmodule HappyTruckerWeb.API.FreightControllerTest do
  use HappyTruckerWeb.ConnCase

  defp add_auth_header(conn, user) do
    Plug.Conn.put_req_header(conn, "authorization", user.token)
  end

  setup _ctx do
    manager = insert(:user, type: "manager")
    driver = insert(:user, type: "driver")

    freight_1 = insert(:freight, start_lat: 1.0, start_long: 1.0)
    freight_2 = insert(:freight, start_lat: 2.0, start_long: 2.0)
    freight_3 = insert(:freight, start_lat: 0.5, start_long: 0.5, status: "assigned")

    %{
      manager: manager,
      driver: driver,
      freight_1: freight_1,
      freight_2: freight_2,
      freight_3: freight_3
    }
  end

  test "GET /api/freights/", ctx do
    resp =
      ctx.conn
      |> add_auth_header(ctx.driver)
      |> get("/api/freights")
      |> json_response(200)

    %{"freights" => list} = resp
    list = Enum.sort(list, &(&1["id"] <= &2["id"]))
    [freight_1, freight_2] = list

    assert freight_1["id"] == ctx.freight_1.id
    assert freight_2["id"] == ctx.freight_2.id
    assert freight_1["distance"] == ctx.freight_1.distance
    assert freight_2["distance"] == ctx.freight_2.distance
    assert freight_1["start_lat"] == ctx.freight_1.start_lat
    assert freight_2["start_lat"] == ctx.freight_2.start_lat
    assert freight_1["start_long"] == ctx.freight_1.start_long
    assert freight_2["start_long"] == ctx.freight_2.start_long
    assert freight_1["finish_lat"] == ctx.freight_1.finish_lat
    assert freight_2["finish_lat"] == ctx.freight_2.finish_lat
    assert freight_1["finish_long"] == ctx.freight_1.finish_long
    assert freight_2["finish_long"] == ctx.freight_2.finish_long
  end

  test "GET /api/freights/ with location", ctx do
    resp =
      ctx.conn
      |> add_auth_header(ctx.driver)
      |> get("/api/freights?lat=3.0&long=3.0")
      |> json_response(200)

    %{"freights" => [freight_2, freight_1]} = resp
    assert freight_1["id"] == ctx.freight_1.id
    assert freight_2["id"] == ctx.freight_2.id
    assert freight_1["distance"] > freight_2["distance"]
  end

  test "GET /api/freights/:id", ctx do
    resp =
      ctx.conn
      |> add_auth_header(ctx.driver)
      |> get("/api/freights/#{ctx.freight_2.id}")
      |> json_response(200)

    %{"freight" => freight} = resp
    assert freight["id"] == ctx.freight_2.id
    assert freight["distance"] == ctx.freight_2.distance
    assert freight["start_lat"] == ctx.freight_2.start_lat
    assert freight["start_long"] == ctx.freight_2.start_long
    assert freight["finish_lat"] == ctx.freight_2.finish_lat
    assert freight["finish_long"] == ctx.freight_2.finish_long
  end

  test "GET /api/freights/:id with distance", ctx do
    resp =
      ctx.conn
      |> add_auth_header(ctx.driver)
      |> get("/api/freights/#{ctx.freight_2.id}?lat=3.0&long=3.0")
      |> json_response(200)

    %{"freight" => freight} = resp
    assert freight["id"] == ctx.freight_2.id
    assert freight["distance"] == 157_177.5518146407
  end

  test "POST /api/freights/", ctx do
    params = %{
      "freight" => %{
        "start_lat" => 1.0,
        "start_long" => 2.0,
        "finish_lat" => 3.0,
        "finish_long" => 4.0
      }
    }

    resp =
      ctx.conn
      |> add_auth_header(ctx.manager)
      |> post("/api/freights/", params)
      |> json_response(200)

    %{"freight" => freight} = resp

    assert freight["distance"] == nil
    assert freight["start_lat"] == 1.0
    assert freight["start_long"] == 2.0
    assert freight["finish_lat"] == 3.0
    assert freight["finish_long"] == 4.0
  end

  test "POST /api/freights/ by wrong user", ctx do
    params = %{
      "freight" => %{
        "start_lat" => 1.0,
        "start_long" => 2.0,
        "finish_lat" => 3.0,
        "finish_long" => 4.0
      }
    }

    ctx.conn
    |> add_auth_header(ctx.driver)
    |> post("/api/freights/", params)
    |> json_response(403)
  end

  test "PUT /api/freights/", ctx do
    params = %{
      "freight" => %{
        "status" => "assigned"
      }
    }

    resp =
      ctx.conn
      |> add_auth_header(ctx.driver)
      |> put("/api/freights/#{ctx.freight_1.id}", params)
      |> json_response(200)

    %{"freight" => freight} = resp

    assert freight["driver_id"] == ctx.driver.id
    assert freight["status"] == "assigned"
  end

  test "PUT /api/freights/ by wrong user", ctx do
    params = %{
      "freight" => %{
        "status" => "assigned"
      }
    }

    ctx.conn
    |> add_auth_header(ctx.manager)
    |> put("/api/freights/#{ctx.freight_1.id}", params)
    |> json_response(403)
  end
end
