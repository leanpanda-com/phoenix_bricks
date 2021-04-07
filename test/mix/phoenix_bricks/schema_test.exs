defmodule Mix.PhoenixBricks.SchemaTest do
  use ExUnit.Case

  alias Mix.PhoenixBricks.Schema

  @schema_name "Context.Schema"
  @filters ["name:matches:string", "count:gte:integer"]

  describe "new/2" do
    setup do
      schema = Schema.new(@schema_name, @filters)

      %{schema: schema}
    end

    test "sets a context_app", %{schema: schema} do
      assert schema.context_app == :phoenix_bricks
    end

    test "sets a module", %{schema: schema} do
      assert schema.module == PhoenixBricks.Context.Schema
    end
  end
end
