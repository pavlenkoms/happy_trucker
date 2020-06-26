defmodule HappyTruckerWeb.API.FallbackController do
  use HappyTruckerWeb, :controller

  import HappyTruckerWeb.ErrorHelpers

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> send_error(
      :unprocessable_entity,
      Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
    )
  end

  def call(conn, {:error, {:invalid_params, %Ecto.Changeset{} = changeset}}) do
    conn
    |> send_error(
      :unprocessable_entity,
      Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
    )
  end

  def call(conn, {:error, {:bad_request, errors}}) when is_map(errors) do
    conn
    |> send_error(:unprocessable_entity, errors)
  end

  def call(conn, {:error, {type, %Ecto.Changeset{} = changeset}}) do
    conn
    |> send_error(type, Ecto.Changeset.traverse_errors(changeset, &translate_error/1))
  end

  def call(conn, {:error, {type, _} = err}) do
    conn
    |> send_error(type, err)
  end

  def call(conn, {:error, error}) do
    conn
    |> send_error(error, error)
  end

  def call(_conn, error) do
    raise "Unknown controller action return value\n#{inspect(error)}"
  end
end
