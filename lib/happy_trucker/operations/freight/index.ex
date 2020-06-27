defmodule HappyTrucker.Freight.Index do
  alias HappyTrucker.{Repo, Params, Freight}

  import Ecto.Query

  use Params,
    params: %{
      lat: :float,
      long: :float
    }

  @spec call(map(), map()) :: {:ok, [Freight.t()]}
  def call(_ctx, params) do
    location = params[:lat] && params[:long] && params

    query = from f in Freight, where: f.status == "new"

    freights =
      query
      |> Repo.all()
      |> sort_freights(location)

    {:ok, freights}
  end

  defp sort_freights([], _) do
    []
  end

  defp sort_freights(freights, nil) do
    freights
  end

  defp sort_freights(freights, location) do
    freights =
      for f <- freights do
        case Freight.GeoUtils.distance(f, location) do
          {:ok, distance} ->
            Map.put(f, :distance, distance)

          _ ->
            nil
        end
      end

    freights
    |> Enum.reject(&is_nil/1)
    |> Enum.sort(&(&1.distance <= &2.distance))
  end
end
