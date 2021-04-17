defmodule Mix.Tasks.Phx.Bricks.Gen.Filter do
  use Mix.Task

  alias Mix.PhoenixBricks.Schema

  @shortdoc "Generates params filter logic for a resource"

  @moduledoc """
  Generates a Filter schema around an Ecto schema
  """

  @doc false
  def run(args) do
    if Mix.Project.umbrella?() do
      Mix.raise(
        "mix phx.bricks.gen.filter must be invoked from within your *_web application root directory"
      )
    end

    args
    |> build()
    |> create_filter_file()
  end

  defp build(args) do
    {_opts, parsed} = OptionParser.parse!(args, strict: [])

    [schema_name | filters] = validate_args!(parsed)

    Schema.new(schema_name, filters)
  end

  defp create_filter_file(%Schema{base_file_path: base_file_path} = schema) do
    Mix.Phoenix.copy_from(
      [".", :phoenix_bricks],
      "priv/templates/phx.bricks.gen",
      [schema: schema],
      [{:eex, "filter.ex", "#{base_file_path}_filter.ex"}]
    )
  end

  defp validate_args!([]), do: raise_with_help("Schema name not provided")
  defp validate_args!([_schema_name]), do: raise_with_help("Provide at least one field")

  defp validate_args!([schema_name | filters] = args) do
    if !Schema.valid_schema_name?(schema_name), do: raise_with_help("Schema name not valid")
    if !Schema.valid_fields?(filters), do: raise_with_help("Fields not valid")
    args
  end

  defp raise_with_help(msg) do
    Mix.raise("""
    #{msg}
    """)
  end
end
