defmodule SlowmonsterWeb.TimeControllerTest do
  use SlowmonsterWeb.ConnCase

  import Slowmonster.Factory

  alias Slowmonster.Tickets
  alias Slowmonster.Tickets.Time

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index with a logged in user" do
    setup [:log_user_in, :create_time]

    test "open lists all open times", %{conn: conn} do
      get_conn = get conn, time_path(conn, :index), open: "true"
      assert Enum.count(json_response(get_conn, 200)["data"]) == 1
    end

    test "open does not list ended times", %{conn: conn, time: time} do
      Tickets.update_time(time, %{ended_at: Timex.now()})
      
      get_conn = get conn, time_path(conn, :index), open: "true"
      assert Enum.count(json_response(get_conn, 200)["data"]) == 0
    end

    test "open does not list open times belonging to other users", %{conn: conn} do
      insert(:time) # a second time record
      
      get_conn = get conn, time_path(conn, :index), open: "true"
      assert Enum.count(json_response(get_conn, 200)["data"]) == 1
    end
  end

  test "index without a logged in user returns a 401", %{conn: conn} do
    conn = get conn, time_path(conn, :index)
    assert response(conn, 401)
  end

  describe "create time with a logged in user" do
    setup [:log_user_in, :create_ticket]

    test "renders time when data is valid", %{conn: conn, ticket: ticket} do
      time_params = Map.put(params_for(:time), :ticket_id, ticket.id)
      post_conn = post conn, time_path(conn, :create), time: time_params
      assert %{"id" => id} = json_response(post_conn, 201)["data"]

      get_conn = get conn, time_path(conn, :show, id)
      assert json_response(get_conn, 200)["data"]["id"] == id
    end

    test "renders errors when data is invalid", %{conn: conn, ticket: ticket} do
      conn = post conn, time_path(conn, :create), time: %{ticket_id: ticket.id}
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when the user does not own the ticket", %{conn: conn} do
      assert_raise Ecto.NoResultsError, fn ->
        post conn, time_path(conn, :create), time: params_for(:time)
      end
    end
  end

  test "create time without a logged in user returns a 401", %{conn: conn} do
    conn = post conn, time_path(conn, :create), time: params_for(:time)
    assert response(conn, 401)
  end

  describe "update time with a logged in user" do
    setup [:log_user_in, :create_time]
  
    test "renders time when data is valid", %{conn: conn, time: %Time{id: id} = time} do
      put_conn = put conn, time_path(conn, :update, time), time: %{ended_at: "2011-05-18T15:01:01.000000Z"}
      assert %{"id" => ^id} = json_response(put_conn, 200)["data"]
  
      get_conn = get conn, time_path(conn, :show, id)
      assert json_response(get_conn, 200)["data"]["ended_at"] == "2011-05-18T15:01:01.000000Z"
    end

    test "renders errors if the user does not own the time", %{conn: conn} do
      time = insert(:time)
      assert_raise Ecto.NoResultsError, fn ->
        put conn, time_path(conn, :update, time), time: %{ended_at: "2011-05-18T15:01:01.000000Z"}
      end
    end
  
    test "renders errors when data is invalid", %{conn: conn, time: time} do
      conn = put conn, time_path(conn, :update, time), time: %{started_at: "abc"}
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete time with a logged in user" do
    setup [:log_user_in, :create_ticket, :create_time]

    test "returns ok when time exists", %{conn: conn, time: time} do
      delete_conn = delete conn, time_path(conn, :delete, time)
      assert response(delete_conn, 204)

      assert_raise Ecto.NoResultsError, fn ->
        get conn, time_path(conn, :show, time.id)
      end
    end

    test "renders errors when time does not exist", %{conn: conn} do
      time = %Time{id: 123}

      assert_raise Ecto.NoResultsError, fn ->
        delete conn, time_path(conn, :delete, time)
      end
    end

    test "renders errors when the user does not own the ticket", %{conn: conn} do
      time = insert(:time)

      assert_raise Ecto.NoResultsError, fn ->
        delete conn, time_path(conn, :delete, time)
      end
    end
  end

  test "delete time without a logged in user returns a 401", %{conn: conn} do
    time = insert(:time)

    conn = delete conn, time_path(conn, :delete, time)
    assert response(conn, 401)
  end

  defp create_time %{user: user} do
    {:ok, ticket: ticket} = create_ticket %{user: user}
    time = insert(:time, ticket_id: ticket.id)
    {:ok, time: time, ticket: ticket}
  end

  defp create_ticket %{user: user} do
    ticket = insert(:ticket, user_id: user.id)
    {:ok, ticket: ticket}
  end

  defp log_user_in %{conn: conn} do
    user = insert(:user)
    session = insert(:session, %{user_id: user.id})

    conn = conn
    |> put_req_header("accept", "application/json")
    |> put_req_header("authorization", "Token token=\"#{session.token}\"")

    {:ok, conn: conn, user: user}
  end
end
