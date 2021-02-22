defmodule Mix.Tasks.Phx.Bricks.Gen.Filter do
  use Mix.Task

  @shortdoc "Generates params filter logic for a resource"

  @moduledoc """
  Generates a Filter schema around an Ecto schema
  """

  @doc false
  def run(_args) do
    if Mix.Project.umbrella?() do
      Mix.raise(
        "mix phx.bricks.gen.filter must be invoked from within your *_web application root directory"
      )
    end
  end
end
