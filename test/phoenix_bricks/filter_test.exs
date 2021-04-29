defmodule PhoenixBricks.FilterTest do
  use ExUnit.Case

  defmodule FilterExample do
    use PhoenixBricks.Filter,
      filters: [
        field_matcher: :string
      ],
      per: 20
  end

  describe "using PhoenixBricks.Filter" do
    test "convert_params_to_scopes/1 returns a list of filters" do
      params = %{"filters" => %{"field_matcher" => "value"}}

      assert FilterExample.convert_params_to_scopes(params) == [field_matcher: "value"]
    end

    test "convert_params_to_scopes/1 with \"page\" adds pagination to scopes" do
      params = %{"filters" => %{"field_matcher" => "value"}, "page" => "3"}

      assert FilterExample.convert_params_to_scopes(params) == [
               field_matcher: "value",
               pagination: {3, 20}
             ]

      params = %{"filters" => %{"field_matcher" => "value"}, "page" => "2", "per" => "10"}

      assert FilterExample.convert_params_to_scopes(params) == [
               field_matcher: "value",
               pagination: {2, 10}
             ]
    end

    test "convert_params_to_scopes/2 with \":with_pagination\" adds pagination" do
      params = %{"filters" => %{"field_matcher" => "value"}}

      assert FilterExample.convert_params_to_scopes(params, :with_pagination) == [
               field_matcher: "value",
               pagination: {1, 20}
             ]

      params = %{"filters" => %{"field_matcher" => "value"}, "page" => "2"}

      assert FilterExample.convert_params_to_scopes(params, :with_pagination) == [
               field_matcher: "value",
               pagination: {2, 20}
             ]

      params = %{"filters" => %{"field_matcher" => "value"}, "per" => "10"}

      assert FilterExample.convert_params_to_scopes(params, :with_pagination) == [
               field_matcher: "value",
               pagination: {1, 10}
             ]
    end

    test "changeset/2" do
      changeset =
        %FilterExample{}
        |> FilterExample.changeset(%{
          "field_matcher" => "value",
          "invalid_field_matcher" => "value"
        })

      assert %Ecto.Changeset{valid?: true, changes: %{field_matcher: "value"}} = changeset

      assert %FilterExample{field_matcher: "value"} = Ecto.Changeset.apply_changes(changeset)
    end
  end
end
