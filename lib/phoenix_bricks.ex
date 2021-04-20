defmodule PhoenixBricks do
  @moduledoc ~S"""
  An opinable set of proposed patters that helps to write reusable and no
  repetitive code for `Contexts`.

  ## Motivation
  After several years in [Ruby on Rails](https://rubyonrails.org) developing I've
  got used to structure code folllowing the Single Responsibility Principle.

  [Phoenix](https://www.phoenixframework.org/) comes with the
  [Context](https://hexdocs.pm/phoenix/contexts.html) concept, a module that cares
  about expose an API of an application section to other sections.

  In a `Context` we usually have at least 6 actions for each defined `schema`
  (`list_records/0`, `get_record!/1`, `create_record/1`, `update_record/2`,
  `delete_record/1`, `change_record/2`).

  If we consider that all Business Logic could go inside the `Context`, it's possibile
  to have a module with hundreds of lines of code, making code mainteinance very
  hard to be guardanteed.

  The idea is to highlight common portion of code that can be extacted and moved
  into a separated module with only one responsibility and that could be reused
  in different contexts.

  ## List records
  The method `list_*` has a default implementation that returns  the list of
  associated record:

  ```elixir
  def list_records do
    MyApp.Context.RecordSchema
    |> MyApp.Repo.all()
  end
  ```

  Let's add now to the context the capability of filtering the collection according
  to an arbitrary set of `scopes`, calling the function in this way:

  ```elixir
  iex> Context.list_records(title_matches: "value")
  ```

  A possible solution could be to delegate the query building into a separated
  `RecordQuery` module
  ```elixir
  defmodule RecordQuery do
    def scope(list_of_filters) do
      RecordSchema
      |> improve_query_with_filters(list_of_filters)
    end

    defp improve_query_with_filters(start_query, list_of_filters) do
      list_of_filters
      |> Enum.reduce(start_query, fn scope, query -> apply_scope(query, scope) end)
    end

    defp apply_scope(query, {:title_matches, "value"}) do
      query
      |> where([q], ...)
    end

    defp apply_scope(query, {:price_lte, value}) do
      query
      |> where([q], ...)
    end
  end
  ```

  and use it into the `Context`
  ```elixir
  def list_records(scopes \\ []) do
    RecordQuery.scope(scopes)
    |> Repo.all()
  end

  iex> Context.list_records(title_matches: "value", price_lte: 42)
  ```

  ### `PhoenixBricks.Query`
  Using `PhoenixBricks.Query` it's possible to extend a module with all scope
  behaviours:
  ```elixir
  defmodule RecordQuery do
    use PhoenixBricks.Query, schema: RecordSchema

    defp apply_scope(query, {:title_matches, "value"}) do
      query
      |> where([q], ...)
    end
  end
  ```

  ## Filter
  Another common feature is to filter records according to params provided through
  url params (for example after a submit in a search form).
  ```elixir
  def index(conn, params)
    filters = Map.get(params, "filters", %{})

    colletion = Context.list_records_based_on_filters(filters)

    conn
    |> assign(:collection, collection)
    ...
  end
  ```
  ensuring to allow only specified filters

  A possible implementation could be:
  ```elixir
  defmodule RecordFilter do
    @search_filters ["title_matches", "price_lte"]

    def convert_filters_to_scopes(filters) do
      filters
      |> Enum.map(fn {name, value} ->
        convert_filter_to_scope(name, value)
      end)
    end

    def convert_filter_to_scope(name, value) when name in @search_fields do
      {String.to_atom(name), value}
    end
  end
  ```

  This way parameters are filtered and converted to a `Keyword` that is the common
  format for the `RecordQuery` described above.
  ```elixir
  iex> RecordFilter.convert_filters_to_scopes(%{"title_matches" => "value", "invalid_scope" => "value"})
  iex> [title_matches: "value"]
  ```

  and we can rewrite the previous action emphasizing the params convertion and
  the collection filter
  ```elixir
  def index(conn, params) do
    filters = Map.get(params, "filters", %{})

    collection =
      filters
      |> RecordFilter.convert_filters_to_scopes()
      |> Context.list_records()

    conn
    |> assign(:collection, collection)
    ....
  end
  ```

  The last part is to build a search form. In order to achieve this, we can add
  schema functionality to `RecordFilter` module:
  ```elixir
  defmodule RecordFilter do
    use Ecto.Schema

    embedded_schema do
      field :title_matches, :string
    end

    def changeset(filter, params) do
      filter
      |> cast(params, [:title_matches])
    end
  end

  def index(conn, params) do
    filters = Map.get(params, "filters", %{})
    filter_changeset = RecordFilter.changeset(%RecordFilter{}, filters)

    collection =
      filters
      |> RecordFilter.convert_filters_to_scopes()
      |> Context.list_records()

    conn
    |> assign(:collection, collection)
    |> assign(:filter_changeset, filter_changeset)
  end
  ```

  ```html
    <%= f = form_for @filter_changeset, .... %>
      <%= label f, :title_matches %>
      <%= text_input f, :title_matches %>

      <%= submit "Filter results" %>
    <% end %>
  ```

  ### `PhoenixBricks.Filter`
  Using `PhoenixBricks.Filter` module it's possible to extend a module with all
  filtering behaviours (define a `changeset` and the filter convertion)
  ```elixir
  defmodule RecordFilter do
    use PhoenixBricks.Filter,
        filters: [
          title_matches: :string
        ]
  end
  ```

  making available `changeset/2` defined above and `convert_filters_to_scopes/1`
  """
end
