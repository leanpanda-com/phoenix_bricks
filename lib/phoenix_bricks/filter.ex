defmodule PhoenixBricks.Filter do
  @moduledoc ~S"""
  Defines a Filter Schema

  ## Examples
  ```elixir
      defmodule RecordFilter do
        use PhoenixBricks.Filter,
            filters: [
              field_matcher: :string
            ]
      end
  ```

  It defines a schema which fields could be used in a search form.

  ## Search changeset
  ```elixir
      def index(conn, params) do
        filters = Map.get(params, "filters", %{})

        conn
        |> assign(:changeset, RecordFilter.changeset(%RecordFilter{}, filters))
        |> render("index.html")
      end
  ```

  ```html
      <%= form_for @conn, Routes.session_path(@conn, :create), [method: :post, as: :user], fn f -> %>
        <div class="form-group">
          <%= label f, :field_matcher %>
          <%= text_input f, :field_matcher %>
        </div>

        <div class="form-group">kab
          <%= submit "Search" %>
        </div>
      <% end %>
  ```

  ## Convertion from map of params to a list of filtered scopes

  ```elixir
      iex> filters = %{"field_matcher" => "value}
      iex> RecordFilter.convert_filter_to_scopes(filters)
      iex> [field_matcher: "value"]
  ```
  """

  defmacro __using__(filters: filters) do
    filter_keys = Keyword.keys(filters)
    filter_string_keys = filter_keys |> Enum.map(&Atom.to_string(&1))

    quote do
      import Ecto.Changeset

      use Ecto.Schema

      @search_fields unquote(filter_string_keys)

      @primary_key false
      embedded_schema do
        unquote do
          for {name, type} <- filters do
            quote do
              field(unquote(name), unquote(type))
            end
          end
        end
      end

      def changeset(filter, attrs) do
        filter
        |> cast(attrs, unquote(filter_keys))
      end

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
  end
end
