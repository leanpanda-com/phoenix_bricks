defmodule <%= inspect schema.module %>Filter do
  @moduledoc """
  Provides an interface to extract a list of scopes from params from a search form.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias <%= inspect schema.module %>Filter

  embedded_schema do
<%= schema.fields |> Enum.map(fn {name, matcher, type} -> "    field :#{name}_#{matcher}, :#{type}" end) |> Enum.join("\n") %>
  end

  def changeset(filter, attrs) do
    filter
    |> cast(attrs, [<%= schema.fields |> Enum.map(fn {name, matcher, _} -> ":#{name}_#{matcher}" end) |> Enum.join(", ") %>])
  end

  @doc """
  Returns a list of scopes extract from params filters discarding filters that aren't valid fields.

      iex> params_to_scope(%{"filters" => %{<%=
        with {name, matcher, _} <- List.first(schema.fields),
          do: "\"#{name}_#{matcher}\" => \"value\", "
      %>not_valid_matcher" => "value"}})
      [<%= with {name, matcher, _} <- List.first(schema.fields), do: "#{name}_#{matcher}: \"value\"" %>]
  """
  def params_to_scope(params) do
    filters = Map.get(params, "filters", %{})

    filter_changeset = changeset(%<%= inspect(schema.module) |> String.split(".") |> List.last() %>Filter{}, filters)

    filter_changeset.changes
    |> Enum.map(fn {name, value} -> {name, value} end)
  end
end
