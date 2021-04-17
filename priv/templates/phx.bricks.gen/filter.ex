defmodule <%= inspect schema.module %>Filter do
  @moduledoc false

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

  def params_to_scope(params) do
    filters = Map.get(params, "filters", %{})

    filter_changeset = changeset(%<%= inspect(schema.module) |> String.split(".") |> List.last() %>Filter{}, filters)

    filter_changeset.changes
    |> Enum.map(fn {name, value} -> {name, value} end)
  end
end
