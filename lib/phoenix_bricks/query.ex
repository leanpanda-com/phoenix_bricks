defmodule PhoenixBricks.Query do
  @moduledoc ~S"""
  Defines a common interface for adding scopes to a Schema

  ## Examples
  ```elixir
  defmodule RecordQuery do
    use PhoenixBricks.Query, schema: Record
  end
  ```

  It provides you a method `scope` that improve the empty scope of provided schema
  with additional scopes.

  `scope/0` returns the empty scope
  ```elixir
  iex> RecordQuery.scope()
  iex> Record
  ```

  With `scope/1` you can provide a list of scopes that improve the starting scope
  ```elixir
  iex> scopes = [field1: {:eq, "value"}, field2: {:gte, 42}]
  iex> RecordQuery.scope(scopes)
  iex> #Ecto.Query<from r0 in Record, where: r0.field1 == ^"value" and r0.field2 >= 42>
  ```

  If you need to improve an existing Ecto.Query you can use `scope/2`
  ```elixir
  iex> starting_scope = from(r in Record, where: r.field1 == "value")
  iex> scopes = [field2: {:gte, 42}]
  iex> RecordQuery.scope(starting_scope, scopes)
  iex> #Ecto.Query<from r0 in Record, where: r0.field1 == ^"value" and r0.field2 >= 42>
  ```

  ## Built-in scopes
  ### `:eq`
  ```elixir
  iex> RecordQuery.scope(field: {:eq, "value"})
  iex> #Ecto.Query<from r0 in Record, where: r0.fields == ^"value">
  ```

  ### `:gt`
  ```elixir
  iex> RecordQuery.scope(field: {:gt, "value"})
  iex> #Ecto.Query<from r0 in Record, where: r0.fields > ^"value">
  ```

  ### `:lt`
  ```elixir
  iex> RecordQuery.scope(field: {:lt, "value"})
  iex> #Ecto.Query<from r0 in Record, where: r0.fields < ^"value">
  ```

  ### `:gte`
  ```elixir
  iex> RecordQuery.scope(field: {:gte, "value"})
  iex> #Ecto.Query<from r0 in Record, where: r0.fields >= ^"value">
  ```

  ### `:lte`
  ```elixir
  iex> RecordQuery.scope(field: {:lte, "value"})
  iex> #Ecto.Query<from r0 in Record, where: r0.fields <= ^"value">
  ```

  ### `:neq`
  ```elixir
  iex> RecordQuery.scope(field: {:neq, "value"})
  iex> #Ecto.Query<from r0 in Record, where: r0.fields != ^"value">
  ```

  ### `:matches`
  ```elixir
  iex> RecordQuery.scope(field: {:matches, "value"})
  iex> #Ecto.Query<from r0 in Record, where: ilike(r0.field, ^"%value%")>
  ```

  ## Customize scopes
  If you need to define more comprehensive scopes you can improve the query adding
  new `apply_scope/2` methods
  ```elixir
  defmodule RecordQuery, do
    use PhoenixBricks.Query, schema: Record

    def apply_scope(query, {:name_matches, "value"}) do
      query
      |> apply_scope(:name, {:matches, "value"})
    end

    def apply_scope(query, :published) do
      query
      |> where([p], p.status == "published")
    end
  end

  iex> RecordQuery.scope(:published, name_matches: "value")
  iex> #Ecto.Query<from r0 in Record, where: r0.status == "published" and ilike(r0.name, ^"%value%")>
  ```
  """

  defmacro __using__(schema: schema) do
    quote do
      import Ecto.Query, warn: false

      def starting_scope do
        unquote(schema)
      end

      def scope(starting_scope, scopes) do
        scopes
        |> Enum.reduce(starting_scope, fn scope, query ->
          apply_scope(query, scope)
        end)
      end

      def scope(scopes) do
        scope(starting_scope(), scopes)
      end

      def scope do
        starting_scope()
      end

      @type query :: Ecto.Query.t()
      @spec apply_scope(query, atom() | {atom(), any()}) :: query
      def apply_scope(query, opts \\ nil)

      def apply_scope(query, {column, {:eq, value}}) do
        where(query, [q], field(q, ^column) == ^value)
      end

      def apply_scope(query, {column, {:neq, value}}) do
        where(query, [q], field(q, ^column) != ^value)
      end

      def apply_scope(query, {column, {:lte, value}}) do
        where(query, [q], field(q, ^column) <= ^value)
      end

      def apply_scope(query, {column, {:lt, value}}) do
        where(query, [q], field(q, ^column) < ^value)
      end

      def apply_scope(query, {column, {:gte, value}}) do
        where(query, [q], field(q, ^column) >= ^value)
      end

      def apply_scope(query, {column, {:gt, value}}) do
        where(query, [q], field(q, ^column) > ^value)
      end

      def apply_scope(query, {column, {:matches, value}}) do
        where(query, [q], ilike(field(q, ^column), ^value))
      end
    end
  end
end
