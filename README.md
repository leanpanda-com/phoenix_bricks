# PhoenixBricks [![Circle CI](https://circleci.com/gh/leanpanda-com/phoenix_bricks/tree/master.svg?style=svg)](https://circleci.com/gh/leanpanda-com/phoenix_bricks/tree/master) [![Coverage Status](https://coveralls.io/repos/github/leanpanda-com/phoenix_bricks/badge.png?branch=master)](https://coveralls.io/github/leanpanda-com/phoenix_bricks?branch=master)
A set of proposed patterns to improve code organization for [Phoenix](https://phoenixframework.org) application

## Installation

To install PhoenixBricks, add it to your list of dependencies in `mix.exs`.

```elixir
def deps do
  [
    {:phoenix_bricks, "~> 0.3.0"}
  ]
end
```

Once you've added PhoenixBricks to your list, update your dependencies by running:

```bash
$ mix deps.get
```

## Getting started
**PhoenixBricks** it is intented as a set of proposed pattern to organize code into a Phoenix application in a modular way.

### Queries
A query is a module that receives a list of atom/keywords and returns an Ecto.Query improved with provided scopes

```elixir
# lib/phoenix_bricks/catalogue/product_query.ex
defmodule PhoenixBricks.Catalogue.ProductQuery do
  use PhoenixBricks.Query
end

[title_matches: "a value", price_is_greater_than: 1000]
|> ProductQuery.scope()
=> #Ecto.Query<from p0 in PhoenixBricks.Catalogue.Product,
 where: ilike(p0.title, ^"%a value%"), where: p0.price >= ^1000
```

The idea is to have a query composer that could be easy to use like [ActiveRecord](https://github.com/rails/rails/tree/main/activerecord).


To generate a query for the `Catalogue.Product` schema with some additional custom scopes, simply run
```elixir
$ mix phx.bricks.gen.query Catalogue.Product name:matches:string price:lte:integer
```

The generated module will contain a set of default scopes for simple column matchers and the additional scopes provided in the command.

```elixir
defmodule PhoenixBricks.Catalogue.ProductQuery do
  @moduledoc false

  import Ecto.Query, warn: false

  def starting_scope do
    PhoenixBricks.Catalogue.Product
  end

  def scope(scopes, starting_scope) do
    scopes
    |> Enum.reduce(starting_scope, fn scope, query ->
      apply_scope(query, scope)
    end)
  end

  def scope(scopes) do
    scope(scopes, starting_scope())
  end

  def scope do
    starting_scope()
  end

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
    value = "%#{value}%"
    where(query, [q], ilike(field(q, ^column), ^value))
  end

  def apply_scope(query, {:title_matches, value}) do
    apply_scope(query, {:title, {:matches, value}})
  end

  def apply_scope(query, {:price_gte, value}) do
    apply_scope(query, {:price, {:gte, value}})
  end
end
```

Using the module `ProductQuery` it's possible to rewrite the `list_products/0` method of the context this way:
```elixir
defmodule PhoenixBricks.Catalogue do
  ...
  def list_products(scopes \\ []) do
    ProductQuery.scope(scopes)
    |> Repo.all()
  end
  ...
end

[title_matches: "a value"]
|> Catalogue.list_products()
```

If you want to add custom scopes you simply have to add new definitions of the `apply_scope/2` method:
```elixir
def apply_scope(query, :active) do
  from(q in query, where: q.active == true)
end

def apply_scope(query, {:some_scope_name, value}) do
  from(query in q, ...)
end
...
Catalogue.list_products([
  :active,
  title_matches: "a value",
  some_scope_name: "some value"
])
```

### Filters
A filter is a module that receives a map of filters (for instance coming from a search form) and returns a list of allowed filters.

```elixir
%{"filters" => %{"title_matches" => "a value", "not_allowed" => "xxx"}}
|> ProductFilter.params_to_scopes()
=> [title_matches: "a value"]
```

To generate a module filter for the schema `Catalogue.Product` you can run
```elixir
$ mix phx.bricks.gen.filters Catalogue.Product title:matches:string price:gte:integer
```

The generated module is a schema that allow you to handle filters from a search form
```elixir
defmodule CrudExample.Catalogue.ProductFilter do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias CrudExample.Catalogue.ProductFilter

  embedded_schema do
    field :title_matches, :string
    field :price_gte, :integer
  end

  def changeset(filter, attrs) do
    filter
    |> cast(attrs, [:title_matches, :price_gte])
  end

  def params_to_scopes(params) do
    filters = Map.get(params, "filters", %{})

    filter_changeset = changeset(%ProductFilter{}, filters)

    filter_changeset.changes
    |> Enum.map(fn {name, value} -> {name, value} end)
  end
end
```

```elixir
# lib/phoenix_bricks/catalogue.ex
def filter_products(params) do
  ProductFilter.changeset(%ProductFilter{}, params)
end


# lib/phoenix_bricks_web/controllers/products_controller.ex
def index(conn, params) do
  filter_changeset =
    ProductFilter.changeset(%ProductFilter{}, params)

  products =
    params
    |> ProductFilter.params_to_scopes()
    |> ProductsQuery.scope()
    |> Repo.all()

    # or
    # params
    # |> ProductsFilter.params_to_scopes()
    # |> Products.list_products()

  render(
    conn,
    "index.html",
    products: products,
    filter_changeset: filter_changeset
  )
end


# lib/phoenix_bricks_web/templates/products/index.html.eex
<%= form_for @filter_changeset, Routes.product_index_path(@conn, :index) method: :get do %>
  <%= label :title_matches %>
  <%= text_input :title_matches %>
<% end %>

<%= for product <- @products do %>
  ...
<% end %>
```

### Query and Filters
The 2 modules can be used in pipeline since the output format for filters are the input format of queries.

```elixir
%{"filters" => %{"title_matches" => "title", "price_gte" => "32"}}
|> ProductFilter.params_to_scopes()
|> ProductQuery.scope()
|> Repo.all()
```
