defmodule Mix.PhoenixBricks.Schema do
  @moduledoc false

  alias Mix.PhoenixBricks.Schema

  defstruct context_app: nil

  def new(_schema_name, _filters) do
    context_app = Mix.Phoenix.context_app()

    %Schema{
      context_app: context_app
    }
  end
end
