defmodule SlowmonsterWeb.SessionControllerTest do
  use SlowmonsterWeb.ConnCase

  alias Slowmonster.Accounts

  @valid_attrs %{username: "foo@bar.com", password: "s3cr3t"}

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@valid_attrs)
    user
  end

  setup %{conn: conn} do
    _ = fixture(:user)
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create session" do
    test "creates and renders resource when data is valid", %{conn: conn} do
      conn = post conn, session_path(conn, :create), user: @valid_attrs
      assert %{"token" => token} = json_response(conn, 201)["data"]

      assert Accounts.find_session_by_token(token)
    end

    test "does not create resource and renders errors when password is invalid", %{conn: conn} do
      conn = post conn, session_path(conn, :create), user: Map.put(@valid_attrs, :password, "notright")
      assert json_response(conn, 401)["errors"] != %{}
    end

    test "does not create resource and renders errors when username is invalid", %{conn: conn} do
      conn = post conn, session_path(conn, :create), user: Map.put(@valid_attrs, :username, "notright")
      assert json_response(conn, 401)["errors"] != %{}
    end
  end
end
