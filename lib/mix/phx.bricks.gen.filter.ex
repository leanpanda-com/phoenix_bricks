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

    schema =
      args
      |> build()
  end

  defp build(args) do
    {_opts, parsed} = OptionParser.parse!(args, strict: [])

    [schema_name | filters] = validate_args!(parsed)

    Schema.new(schema_name, filters)
  end

  defp validate_args!([]), do: raise_with_help("Schema name not provided")

  defp validate_args!([schema | _filters] = args) do
    if Schema.valid_schema_name?(schema), do: args, else: raise_with_help("Schema name not valid")
  end

  defp raise_with_help(msg) do
    Mix.raise("""
    #{msg}
    """)
  end
end
