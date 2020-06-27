defmodule HappyTruckerWeb.FreightView do
  use HappyTruckerWeb, :view

  def render("index.json", %{freights: freights}) do
    %{
      freights: Enum.map(freights, &freight/1)
    }
  end

  def render("show.json", %{freight: freight}) do
    %{
      freights: freight(freight)
    }
  end

  defp freight(freight) do
    freight
    |> Map.take([:id, :start_lat, :start_long, :finish_lat, :finish_long, :driver_id])
  end
end
