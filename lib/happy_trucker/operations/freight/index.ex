defmodule HappyTrucker.Freight.Index do
  alias HappyTrucker.{Repo, Params, Freight}

  import Ecto.Query

  use Params,
    params: %{
      location: %{
        lat!: :float,
        long!: :float
      }
    }

  def call(_ctx, params) do
    query = from f in Freight, where: f.status == "new"

    freights =
      query
      |> Repo.all()
      |> sort_freights(params[:location])

    {:ok, freights}
  end

  defp sort_freights([], _) do
    {:ok, []}
  end

  defp sort_freights(freights, nil) do
    {:ok, freights}
  end

  defp sort_freights(freights, location) do
    freights =
      for f <- freights do
        distance = Freight.GeoUtils.distance([location.lat, location.long], [f.lat, f.long])
        Map.put(f, :distance, distance)
      end

    Enum.sort(freights, &(&1.distance >= &2.distance))
  end
end
