defmodule SlowmonsterWeb.PageControllerTest do
  use SlowmonsterWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "slowmonster web-page"
  end
end
