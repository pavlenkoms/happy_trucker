defmodule HappyTrucker.Params do
  defmacro __using__(opts \\ []) do
    quote do
      defmodule Module.concat(__MODULE__, Params) do
        use Params.Schema, Keyword.get(unquote(opts), :params, %{})
      end

      import HappyTrucker.Params

      @spec run(map(), map()) :: :ok | {:ok, any()} | {:error, any()}
      def run(ctx, params) do
        ctx
        |> subrun(params)
        |> case do
          :ok -> :ok
          {:ok, result} -> {:ok, result}
          {:error, reason} -> {:error, reason}
          {:error, _, reason, _} -> {:error, reason}
        end
      end

      @spec subrun(map(), map()) :: :ok | {:ok, any()} | {:error, any()} | {:error, Ecto.Multi.name(), any(), %{required(Ecto.Multi.name()) => any()}}
      def subrun(ctx, params) do
        with changeset = Module.concat(__MODULE__, Params).from(params),
             true <- changeset.valid? || {:error, {:invalid_params, changeset}},
             {:ok, changeset} <- check_and_setback_empty_values(changeset, params) do
          __MODULE__.call(ctx, Params.to_map(changeset))
        end
      end

      defp check_and_setback_empty_values(changeset, params) do
        {changeset, errors} = setback_empty_embeds(changeset, params, [])

        case flat_reverse_list(errors) do
          [] -> {:ok, changeset}
          [_ | _] = errors -> {:error, {:invalid_params, errors}}
          errors -> {:error, {:unknown_error_format, errors}}
        end
      end

      defp setback_empty_embeds(changeset, %{} = params, stack) do
        {changeset, errors} = changeset |> setback_empty_values(params, stack)

        Enum.reduce(changeset.changes, {changeset, errors}, fn
          {key, %Ecto.Changeset{} = embed}, {acc, error_list} ->
            string_key = to_string(key)

            case params[string_key] do
              %{} = params ->
                {changeset, errors} = setback_empty_embeds(embed, params, [string_key | stack])
                {acc |> Ecto.Changeset.put_change(key, changeset), [errors | error_list]}

              _ ->
                {acc, error_list}
            end

          _, acc ->
            acc
        end)
      end

      defp setback_empty_values(changeset, params, stack) do
        Enum.reduce(params, {changeset, []}, fn
          {key, value}, {acc, error_list} when value in ["", []] ->
            acc.data.__struct__.__changeset__
            |> Map.keys()
            |> Enum.find(&(to_string(&1) == key))
            |> case do
              nil ->
                {acc, error_list}

              atom_key ->
                error =
                  check_empty_string(atom_key, value, acc.data.__struct__.__changeset__, [
                    key | stack
                  ])

                {%{acc | changes: Map.put(acc.changes, atom_key, value)}, [error | error_list]}
            end

          _, acc ->
            acc
        end)
      end

      @string_types [:binary_id, :string, :uuid]
      defp check_empty_string(key, "", format, stack) do
        case format[key] do
          string when string in @string_types ->
            []

          not_atom when not is_atom(not_atom) ->
            "Value type should be #{inspect(not_atom)} value path is: #{
              inspect(flat_reverse_list(stack))
            }"

          atom ->
            with true <- function_exported?(atom, :__info__, 1),
                 true <- atom.type() in @string_types do
              []
            else
              _ ->
                "Value type should be #{inspect(atom)}, value path is: #{
                  inspect(flat_reverse_list(stack))
                }"
            end
        end
      end

      defp check_empty_string(_key, [], _format, _stack) do
        []
      end

      defp flat_reverse_list(list), do: list |> List.flatten() |> Enum.reverse()
    end
  end

  @spec make_ctx(map()) :: map()
  def make_ctx(data) do
    Map.take(data, [:current_user])
  end
end
