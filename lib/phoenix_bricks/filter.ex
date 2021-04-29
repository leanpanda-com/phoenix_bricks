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

  defmacro __using__(opts) do
    filters = Keyword.get(opts, :filters, [])
    per = Keyword.get(opts, :per, 25)

    quote do
      import Ecto.Changeset

      use Ecto.Schema

      @default_per unquote(per)

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

      def convert_params_to_scopes(params, :with_pagination) do
        params
        |> Map.put_new("page", 1)
        |> Map.put_new("per", @default_per)
        |> convert_params_to_scopes()
      end

      def convert_params_to_scopes(params) do
        filters = Map.get(params, "filters", %{})
        filter_changeset = changeset(__struct__(), filters)

        filter_changeset.changes
        |> Enum.map(fn {name, value} -> {name, value} end)
        |> maybe_add_pagination(params)
      end

      defp maybe_add_pagination(scopes, %{"page" => page} = params) do
        per = Map.get(params, "per", @default_per)

        scopes ++ [pagination: {String.to_integer("#{page}"), String.to_integer("#{per}")}]
      end

      defp maybe_add_pagination(scopes, _), do: scopes
    end
  end
end
