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

    test "sets fields", %{schema: schema} do
      assert schema.fields == [
               {"name", "matches", "string"},
               {"count", "gte", "integer"}
             ]
    end
  end

  describe "valid_schema_name?/1" do
    test "with valid schema_name validates it" do
      assert Schema.valid_schema_name?(@schema_name)
    end

    test "with invalid schema_name doens't validate it" do
      refute Schema.valid_schema_name?("Context")
      refute Schema.valid_schema_name?("context.schema")
      refute Schema.valid_schema_name?("Context.schema")
      refute Schema.valid_schema_name?("context.Schema")
      refute Schema.valid_schema_name?("")
    end

    test "with non binary schema_name doens't validate it" do
      refute Schema.valid_schema_name?(1)
      refute Schema.valid_schema_name?('')
      refute Schema.valid_schema_name?(nil)
    end
  end
end
