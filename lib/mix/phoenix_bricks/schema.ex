defmodule Mix.PhoenixBricks.Schema do
  @moduledoc false

  alias Mix.PhoenixBricks.Schema

  defstruct base_file_path: nil,
            context_app: nil,
            fields: [],
            module: nil

  @valid_matchers ~w(eq neq lt lte gt gte in matches)

  def new(schema_name, filters) do
    context_app = Mix.Phoenix.context_app()
    base = Mix.Phoenix.context_base(context_app)
    basename = Phoenix.Naming.underscore(schema_name)
    base_file_path = Mix.Phoenix.context_lib_path(context_app, basename)
    module = Module.concat([base, schema_name])
    fields = extract_fields(filters)

    %Schema{
      base_file_path: base_file_path,
      context_app: context_app,
      fields: fields,
      module: module
    }
  end

  def valid_schema_name?(schema_name) when is_binary(schema_name),
    do: schema_name =~ ~r/^[A-Z]\w*\.[A-Z]\w*$/

  def valid_schema_name?(_), do: false

  def valid_fields?(fields) do
    fields
    |> split_fields()
    |> Enum.all?(&(Enum.at(&1, 1) in @valid_matchers))
  end

  defp split_fields(fields), do: Enum.map(fields, &String.split(&1, ":"))

  defp extract_fields(fields) do
    fields
    |> split_fields()
    |> Enum.map(fn [name, matcher, type] -> {name, matcher, type} end)
  end
end
