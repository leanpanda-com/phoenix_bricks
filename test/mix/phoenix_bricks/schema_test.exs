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

    test "sets base_file_path", %{schema: schema} do
      assert schema.base_file_path == "lib/phoenix_bricks/context/schema"
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

  describe "valid_fields?/1" do
    test "with valid matchers validate it" do
      assert Schema.valid_fields?(["title:eq:string"])
      assert Schema.valid_fields?(["title:neq:string"])
      assert Schema.valid_fields?(["title:gt:string"])
      assert Schema.valid_fields?(["title:gte:string"])
      assert Schema.valid_fields?(["title:lt:string"])
      assert Schema.valid_fields?(["title:lte:string"])
      assert Schema.valid_fields?(["title:matches:string"])
      assert Schema.valid_fields?(["title:in:string"])
    end

    test "with invalid matchers doens't validate it" do
      refute Schema.valid_fields?(["title:not_valid_matcher:string"])
    end
  end
end
