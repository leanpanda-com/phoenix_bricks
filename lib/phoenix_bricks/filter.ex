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
  iex> params = %{"filters" => %{"field_matcher" => "value"}}
  iex> RecordFilter.convert_params_to_scopes(params)
  iex> [field_matcher: "value"]
  ```
  """

  defmacro __using__(filters: filters) do
    quote do
      import Ecto.Changeset

      use Ecto.Schema

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
        |> cast(attrs, unquote(Keyword.keys(filters)))
      end

      def convert_params_to_scopes(params) do
        filters = Map.get(params, "filters", %{})
        filter_changeset = changeset(__struct__(), filters)

        filter_changeset.changes
        |> Enum.map(fn {name, value} -> {name, value} end)
      end
    end
  end
end
