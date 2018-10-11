defmodule MergenWeb.PageControllerTest do
  use MergenWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Summary"
  end
end
