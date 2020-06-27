defmodule HappyTruckerWeb.API.FreightView do
  use HappyTruckerWeb, :view

  def render("index.json", %{freights: freights}) do
    %{
      freights: Enum.map(freights, &freight/1)
    }
  end

  def render("show.json", %{freight: freight}) do
    %{
      freight: freight(freight)
    }
  end

  defp freight(freight) do
    freight
    |> Map.take([
      :id,
      :start_lat,
      :start_long,
      :finish_lat,
      :finish_long,
      :driver_id,
      :distance,
      :status
    ])
  end
end
