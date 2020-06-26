defmodule HappyTrucker.Freight do
  use Ecto.Schema
  import Ecto.Changeset

  @statuses ~w(new assigned done)

  schema "freights" do
    field(:lat, :float)
    field(:long, :float)
    field(:status, :string)
    belongs_to(:driver, HappyTrucker.User)
  end

  @fields ~w(lat long status driver_id)
  @required_fields ~w(lat long status)
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:status, @statuses)
    |> validate_inclusion(:lat, less_than_or_equal_to: 90.0, greater_than_or_equal_to: -90.0)
    |> validate_inclusion(:long, less_than_or_equal_to: 180.0, greater_than_or_equal_to: -180.0)
  end
end
