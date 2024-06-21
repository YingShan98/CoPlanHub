defmodule CoPlanHubWeb.ErrorJSONTest do
  use CoPlanHubWeb.ConnCase, async: true

  test "renders 404" do
    assert CoPlanHubWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert CoPlanHubWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
