defmodule HappyTrucker.Freight do
  use Ecto.Schema
  import Ecto.Changeset

  @statuses ~w(new assigned done)

  schema "freights" do
    field(:start_lat, :float)
    field(:start_long, :float)
    field(:finish_lat, :float)
    field(:finish_long, :float)
    field(:status, :string)
    field(:distance, :float, virtual: true)
    belongs_to(:driver, HappyTrucker.User)
  end

  @fields ~w(start_lat start_long finish_lat finish_long status driver_id)
  @required_fields ~w(start_lat start_long finish_lat finish_long status)
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:status, @statuses)
    |> validate_inclusion(:start_lat, less_than_or_equal_to: 90.0, greater_than_or_equal_to: -90.0)
    |> validate_inclusion(:start_long,
      less_than_or_equal_to: 180.0,
      greater_than_or_equal_to: -180.0
    )
    |> validate_inclusion(:finish_lat,
      less_than_or_equal_to: 90.0,
      greater_than_or_equal_to: -90.0
    )
    |> validate_inclusion(:finish_long,
      less_than_or_equal_to: 180.0,
      greater_than_or_equal_to: -180.0
    )
  end
end
