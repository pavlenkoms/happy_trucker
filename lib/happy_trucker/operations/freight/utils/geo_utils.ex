defmodule HappyTrucker.Freight.GeoUtils do
  alias HappyTrucker.Freight

  def distance(%Freight{} = freight, %{lat: lat, long: long} = _loc) do
    {:ok, Geocalc.distance_between([lat, long], [freight.start_lat, freight.start_long])}
  end

  def distance(%Freight{} = _freight, loc) do
    {:error, {:unprocessible_entity, "bad location: #{inspect(loc)}"}}
  end

  def distance(freight, _loc) do
    {:error, {:unprocessible_entity, "bad freight: #{inspect(freight)}"}}
  end
end
