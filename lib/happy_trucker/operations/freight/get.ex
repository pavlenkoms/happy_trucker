defmodule HappyTrucker.Freight.Get do
  alias HappyTrucker.{Repo, Params, Freight}

  use Params,
    params: %{
      id!: :id,
      lat: :float,
      long: :float
    }

  def call(_ctx, params) do
    location = params[:lat] && params[:long] && params

    with %Freight{} = freight <- Repo.get(Freight, params.id),
         %Freight{} = freight <- calculate_distance(freight, location) do
      {:ok, freight}
    else
      nil -> {:error, :not_found}
      err -> err
    end
  end

  defp calculate_distance(freight, nil) do
    freight
  end

  defp calculate_distance(freight, location) do
    case Freight.GeoUtils.distance(freight, location) do
      {:error, _} = _err -> freight
      {:ok, distance} -> Map.put(freight, :distance, distance)
    end
  end
end
