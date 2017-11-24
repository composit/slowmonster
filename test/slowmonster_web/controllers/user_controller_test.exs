defmodule SlowmonsterWeb.UserControllerTest do
  use SlowmonsterWeb.ConnCase

  import Slowmonster.Factory

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create user" do
    test "renders user when data is valid", %{conn: conn} do
      conn = post conn, user_path(conn, :create), user: params_for(:user)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, user_path(conn, :show, id)
      assert json_response(conn, 200)["data"]["id"] == id
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, user_path(conn, :create), user: %{}
      assert json_response(conn, 422)["errors"] != %{}
    end
  end
end
