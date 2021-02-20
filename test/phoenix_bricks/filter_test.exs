defmodule PhoenixBricks.FilterTest do
  use ExUnit.Case

  defmodule FilterExample do
    use PhoenixBricks.Filter,
      filters: [
        field_matcher: :string
      ]
  end

  describe "using PhoenixBricks.Filter" do
    test "convert_filters_to_scopes/1" do
      params = %{"filters" => %{"field_matcher" => "value"}}

      assert FilterExample.convert_filters_to_scopes(params["filters"]) == [
               field_matcher: "value"
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
