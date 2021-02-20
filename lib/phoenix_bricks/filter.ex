defmodule PhoenixBricks.Filter do
  @moduledoc false

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
