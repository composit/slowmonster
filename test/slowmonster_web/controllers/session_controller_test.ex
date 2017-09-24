defmodule SlowmonsterWeb.SessionControllerTest do
  use SlowmonsterWeb.ConnCase

  alias Slowmonster.Accounts
  alias Slowmonster.Accounts.Session
  alias Slowmonster.Accounts.User
  @valid_attrs %{email: "foo@bar.com", password: "s3cr3t"}

  def fixture(:session) do
    {:ok, session} = Accounts.create_session(@valid_attrs)
    session
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create session" do
    test "creates and renders resource when data is valid", %{conn: conn} do
      conn = post conn, session_path(conn, :create), user: @valid_attrs
      assert %{"token" => token} = json_response(conn, 201)["data"]

      assert Repo.get_by(Session, token: token)
    end

    test "does not create resource and renders errors when password is invalid", %{conn: conn} do
      conn = post conn, session_path(conn, :create), user: Map.put(@valid_attrs, :password, "notright")
      assert json_response(conn, 401)["errors"] != %{}
    end

    test "does not create resource and renders errors when email is invalid", %{conn: conn} do
      conn = post conn, session_path(conn, :create), user: Map.put(@valid_attrs, :email, "not@found.com")
      assert json_response(conn, 401)["errors"] != %{}
    end
  end
end
