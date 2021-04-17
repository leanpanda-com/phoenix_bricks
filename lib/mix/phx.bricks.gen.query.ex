defmodule Mix.Tasks.Phx.Bricks.Gen.Query do
  use Mix.Task

  alias Mix.PhoenixBricks.Schema

  @shortdoc "Generates query logic for a resource"

  @moduledoc """
  Generates a Query module that improves an Ecto.Query of provided schema
  """

  @doc false
  def run(args) do
    if Mix.Project.umbrella?() do
      Mix.raise(
        "mix phx.bricks.gen.query must be invoked from within your *_web application root directory"
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
      [{:eex, "query.ex", "#{base_file_path}_query.ex"}]
    )
  end

  defp validate_args!([]), do: raise_with_help("Schema name not provided")

  defp validate_args!([schema_name | filters] = args) do
    if !Schema.valid_schema_name?(schema_name), do: raise_with_help("Schema name not valid")
    if !Schema.valid_fields?(filters), do: raise_with_help("Fields not valid")
    args
  end

  defp raise_with_help(msg) do
    Mix.raise("""
    #{msg}
    mix phx.bricks.gen.query expects a schema module name.
    For example:
    mix phx.bricks.gen.query Product
    The query serves as schema that improves an Ecto.Query with additional querys listed
    in provided list.
    """)
  end
end
