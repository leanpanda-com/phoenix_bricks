defmodule Mix.PhoenixBricks.Schema do
  @moduledoc false

  alias Mix.PhoenixBricks.Schema

  defstruct context_app: nil,
            module: nil

  def new(schema_name, _filters) do
    context_app = Mix.Phoenix.context_app()
    base = Mix.Phoenix.context_base(context_app)
    module = Module.concat([base, schema_name])

    %Schema{
      context_app: context_app,
      module: module
    }
  end
end
