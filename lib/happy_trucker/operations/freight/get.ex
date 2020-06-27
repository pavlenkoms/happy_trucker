defmodule HappyTrucker.Freight.Get do
  alias HappyTrucker.{Repo, Params, Freight}

  use Params,
    params: %{
      id!: :id,
      location: %{
        lat!: :float,
        long!: :float
      }
    }

  def call(_ctx, params) do
    with %Freight{} = freight <- Repo.get(Freight, params.id),
         %Freight{} = freight <- calculate_distance(freight, params[:location]) do
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
      {:error, _} = err -> err
      distance -> Map.put(freight, :distance, distance)
    end
  end
end
