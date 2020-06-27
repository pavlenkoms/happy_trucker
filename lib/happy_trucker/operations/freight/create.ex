defmodule HappyTrucker.Freight.Create do
  alias HappyTrucker.{Repo, Params, Freight}

  use Params,
    params: %{
      freight!: %{
        start_lat!: :float,
        start_long!: :float,
        finish_lat!: :float,
        finish_long!: :float
      }
    }

  def call(_ctx, params) do
    params = Map.put(params, :status, "new")
    %Freight{} |> Freight.changeset(params) |> Repo.insert()
  end
end
