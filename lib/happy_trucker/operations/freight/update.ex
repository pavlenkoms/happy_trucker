defmodule HappyTrucker.Freight.Update do
  alias HappyTrucker.{Repo, Params, Freight}
  alias Ecto.Multi

  use Params,
    params: %{
      id!: :id,
      freight: %{
        status!: :string
      }
    }

  def call(ctx, params) do
    Multi.new()
    |> Multi.run(:freight, fn _, changes -> do_freight(ctx, params, changes) end)
    |> Multi.run(:validate_freight, fn _, changes -> do_validate_freight(ctx, params, changes) end)
    |> Multi.run(:update, fn _, changes -> do_update(ctx, params, changes) end)
  end

  defp do_freight(_ctx, params, _changes) do
    case Repo.get(Freight, params.id) do
      %Freight{} = freight -> {:ok, freight}
      nil -> {:error, {:not_found, "freight not found"}}
    end
  end

  defp do_validate_freight(
         _ctx,
         %{freight: %{status: "assigned"}} = _params,
         %{freight: %{status: "new"} = freight} = _changes
       ) do
    case freight.driver_id do
      nil ->
        {:ok, nil}

      _ ->
        {:error, {:forbidden, "freight is busy"}}
    end
  end

  defp do_validate_freight(
         ctx,
         %{freight: %{status: "done"}} = _params,
         %{freight: %{status: "assigned"} = freight} = _changes
       ) do
    if freight.driver_id == ctx.current_user.id do
      {:ok, nil}
    else
      {:error, {:forbidden, "freight is not belonging to user!"}}
    end
  end

  defp do_validate_freight(_ctx, _params, _changes) do
    {:error, {:unprocessable_entity, "bad status"}}
  end

  defp do_update(ctx, params, changes) do
    freight_params = Map.put(params.freight, :driver_id, ctx.current_user.id)
    changes.freight |> Freight.changeset(freight_params) |> Repo.update()
  end
end
