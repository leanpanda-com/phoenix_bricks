defmodule Mix.PhoenixBricks.Schema do
  @moduledoc false

  alias Mix.PhoenixBricks.Schema

  defstruct context_app: nil,
            fields: [],
            module: nil

  def new(schema_name, filters) do
    context_app = Mix.Phoenix.context_app()
    base = Mix.Phoenix.context_base(context_app)
    module = Module.concat([base, schema_name])
    fields = extract_fields(filters)

    %Schema{
      context_app: context_app,
      fields: fields,
      module: module
    }
  end

  def valid_schema_name?(schema_name) when is_binary(schema_name),
    do: schema_name =~ ~r/^[A-Z]\w*\.[A-Z]\w*$/

  def valid_schema_name?(_), do: false

  defp extract_fields(filters) do
    filters
    |> Enum.map(&String.split(&1, ":"))
    |> Enum.map(fn [name, matcher, type] -> {name, matcher, type} end)
  end
end
