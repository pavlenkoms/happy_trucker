defmodule HappyTrucker.Freight.Create do
  alias HappyTrucker.{Repo, Params, Freight}

  use Params,
    params: %{
      freight: %{
        lat!: :float,
        long!: :float
      }
    }

  def call(_ctx, params) do
    params = Map.put(params, :status, "new")
    %Freight{} |> Freight.changeset(params) |> Repo.insert()
  end
end
