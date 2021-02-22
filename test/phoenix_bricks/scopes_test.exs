defmodule PhoenixBricks.ScopesTest do
  use ExUnit.Case

  defmodule Record do
    use Ecto.Schema

    embedded_schema do
      field(:title, :string)
      field(:count, :integer)
    end
  end

  defmodule QueryExample do
    use PhoenixBricks.Scopes, schema: Record
  end

  defp convert_wheres_to_text(wheres) do
    wheres
    |> Enum.map(&Macro.to_string(&1.expr))
    |> Enum.join(" and ")
  end

  test "scope/0 returns a queryable" do
    assert QueryExample.scope() == Record
  end

  test "scope/1 with a list of scopes returns a queryable" do
    query = QueryExample.scope(title: {:eq, "value"}, price: {:gte, 10})

    where_fragment = convert_wheres_to_text(query.wheres)

    assert where_fragment == "&0.title() == ^0 and &0.price() >= ^0"
  end

  test "scope/2 with a query and a list of scopes returns a queryable" do
    starting_scope = QueryExample.scope(title: {:eq, "value"})
    query = QueryExample.scope(starting_scope, price: {:lte, 10})

    where_fragment = convert_wheres_to_text(query.wheres)

    assert where_fragment == "&0.title() == ^0 and &0.price() <= ^0"
  end

  test "scope/1 supports :eq matcher" do
    query = QueryExample.scope(price: {:eq, 10})

    where_fragment = convert_wheres_to_text(query.wheres)

    assert where_fragment == "&0.price() == ^0"
  end

  test "scope/1 supports :neq matcher" do
    query = QueryExample.scope(price: {:neq, 10})

    where_fragment = convert_wheres_to_text(query.wheres)

    assert where_fragment == "&0.price() != ^0"
  end

  test "scope/1 supports :lt matcher" do
    query = QueryExample.scope(price: {:lt, 10})

    where_fragment = convert_wheres_to_text(query.wheres)

    assert where_fragment == "&0.price() < ^0"
  end

  test "scope/1 supports :lte matcher" do
    query = QueryExample.scope(price: {:lte, 10})

    where_fragment = convert_wheres_to_text(query.wheres)

    assert where_fragment == "&0.price() <= ^0"
  end

  test "scope/1 supports :gt matcher" do
    query = QueryExample.scope(price: {:gt, 10})

    where_fragment = convert_wheres_to_text(query.wheres)

    assert where_fragment == "&0.price() > ^0"
  end

  test "scope/1 supports :gte matcher" do
    query = QueryExample.scope(price: {:gte, 10})

    where_fragment = convert_wheres_to_text(query.wheres)

    assert where_fragment == "&0.price() >= ^0"
  end
end
