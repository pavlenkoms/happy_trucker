defmodule HappyTrucker.Freight.CreateTest do
  use HappyTrucker.DataCase
  alias HappyTrucker.Freight.{Create, Update, Index, Get}

  describe "create" do
    setup do
      manager = insert(:user, type: "manager")
      driver = insert(:user, type: "driver")
      params = %{
        "freight" => %{
          "start_lat" => 1.0,
          "start_long" => 2.0,
          "finish_lat" => 3.0,
          "finish_long" => 4.0
        }
      }
      %{
        manager: manager,
        driver: driver,
        ctx: make_ctx(manager),
        params: params
      }
    end

    test "create freight success", ctx do
      {:ok, freight} = Create.run(ctx.ctx, ctx.params)
      assert freight.start_lat == 1.0
      assert freight.start_long == 2.0
      assert freight.finish_lat == 3.0
      assert freight.finish_long == 4.0
      assert freight.status == "new"
      assert freight.driver_id == nil
      assert freight.distance == nil
    end

    test "create freight fail not number", ctx do
      params =
        ctx.params
        |> put_in(["freight", "start_lat"], "not_number")

      {:error, {:invalid_params, _}} = Create.run(ctx.ctx, params)
    end

    test "create freight fail out of bounds", ctx do
      params =  %{
        "freight" => %{
          "start_lat" => 91,
          "start_long" => 181,
          "finish_lat" => 91,
          "finish_long" => 181
        }
      }

      {:error, changeset} = Create.run(ctx.ctx, params)

      assert %{
        start_lat: ["must be less than or equal to 90.0"],
        finish_lat: ["must be less than or equal to 90.0"],
        start_long: ["must be less than or equal to 180.0"],
        finish_long: ["must be less than or equal to 180.0"]
      } == errors_on(changeset)

      params =  %{
        "freight" => %{
          "start_lat" => -91,
          "start_long" => -181,
          "finish_lat" => -91,
          "finish_long" => -181
        }
      }

      {:error, changeset} = Create.run(ctx.ctx, params)

      assert %{
        start_lat: ["must be greater than or equal to -90.0"],
        finish_lat: ["must be greater than or equal to -90.0"],
        start_long: ["must be greater than or equal to -180.0"],
        finish_long: ["must be greater than or equal to -180.0"]
      } == errors_on(changeset)
    end
  end

  describe "update" do
    setup do
      manager = insert(:user, type: "manager")
      driver = insert(:user, type: "driver")
      freight = insert(:freight)
      params = %{
        "id" => freight.id,
        "freight" => %{
          "status" => "assigned"
        }
      }
      %{
        manager: manager,
        driver: driver,
        freight: freight,
        ctx: make_ctx(driver),
        params: params
      }
    end

    test "update freight success", ctx do
      {:ok, freight} = Update.run(ctx.ctx, ctx.params)
      assert freight.start_lat == 1.0
      assert freight.start_long == 1.0
      assert freight.finish_lat == 3.0
      assert freight.finish_long == 3.0
      assert freight.driver_id == ctx.driver.id
      assert freight.status == "assigned"
      assert freight.distance == nil
    end

    test "update freight fail to done but not assigned", ctx do
      params = put_in(ctx.params, ["freight", "status"], "done")
      {:error, {:unprocessable_entity, "bad status"}} = Update.run(ctx.ctx, params)
    end

    test "update freight fail to done but wrong driver", ctx do
      driver = insert(:user, type: "driver")
      freight = insert(:freight, status: "assigned", driver: driver)

      params = %{
        "id" => freight.id,
        "freight" => %{
          "status" => "done"
        }
      }
      {:error, {:forbidden, "freight not belongs to user"}} = Update.run(ctx.ctx, params)
    end

    test "update freight fail bad status", ctx do
      params = put_in(ctx.params, ["freight", "status"], "1234")
      {:error, {:unprocessable_entity, "bad status"}} = Update.run(ctx.ctx, params)
    end
  end

  describe "index" do
    setup do
      driver = insert(:user, type: "driver")
      freight_1 = insert(:freight, start_lat: 1.0, start_long: 1.0)
      freight_2 = insert(:freight, start_lat: 2.0, start_long: 2.0)
      freight_3 = insert(:freight, start_lat: 0.5, start_long: 0.5, status: "assigned")

      %{
        driver: driver,
        ctx: make_ctx(driver),
        freight_1: freight_1,
        freight_2: freight_2,
        freight_3: freight_3
      }
    end

    test "index freight success", ctx do
      {:ok, [freight_1, freight_2]} = Index.run(ctx.ctx, %{})

      assert freight_1.distance == nil
      assert freight_2.distance == nil
    end

    test "index freight success with distance", ctx do
      {:ok, [freight_1, freight_2]} = Index.run(ctx.ctx, %{"lat" => 0.0, "long" => 0.0})

      assert freight_1.distance < freight_2.distance
    end
  end

  describe "get" do
    setup do
      driver = insert(:user, type: "driver")
      freight_1 = insert(:freight, start_lat: 1.0, start_long: 1.0)
      freight_2 = insert(:freight, start_lat: 2.0, start_long: 2.0)

      %{
        driver: driver,
        ctx: make_ctx(driver),
        freight_1: freight_1,
        freight_2: freight_2
      }
    end

    test "get freight success", ctx do
      {:ok, freight} = Get.run(ctx.ctx, %{"id" => ctx.freight_2.id})

      assert freight.distance == nil
      assert freight == ctx.freight_2
    end

    test "get freight success with distance", ctx do
      {:ok, freight} = Get.run(ctx.ctx, %{"id" => ctx.freight_2.id, "lat" => 0.0, "long" => 0.0})

      assert freight.distance == 314474.80510086863
      assert freight.id == ctx.freight_2.id
    end

    test "get freight fail not_found", ctx do
      {:error, :not_found} = Get.run(ctx.ctx, %{"id" => ctx.freight_2.id + 1})
    end

    test "get freight fail bad_id", ctx do
      {:error, {:invalid_params, changeset}} = Get.run(ctx.ctx, %{"id" => "asdfd"})

      assert %{id: ["is invalid"]} == errors_on(changeset)
    end
  end
end
