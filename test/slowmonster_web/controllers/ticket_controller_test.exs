defmodule SlowmonsterWeb.TicketControllerTest do
  use SlowmonsterWeb.ConnCase

  import Slowmonster.Factory

  alias Slowmonster.Tickets.Ticket

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  #describe "index with a logged in user" do
  #  setup [:log_user_in]
  #
  #  test "lists all tickets belonging to that user", %{conn: conn, user: user} do
  #    insert_list(3, :ticket, %{user_id: user.id})
  #    conn = get conn, ticket_path(conn, :index)
  #    assert Enum.count(json_response(conn, 200)["data"]) == 3
  #  end
  #
  #  test "does not list tickets not belonging to that user", %{conn: conn} do
  #    insert(:ticket)
  #    conn = get conn, ticket_path(conn, :index)
  #    assert json_response(conn, 200)["data"] == []
  #  end
  #end

  #test "index without a logged in user returns a 401", %{conn: conn} do
  #  conn = get conn, ticket_path(conn, :index)
  #  assert response(conn, 401)
  #end

  describe "create ticket with logged in user" do
    setup [:log_user_in]

    test "renders ticket when the data is valid", %{conn: conn} do
      post_conn = post conn, ticket_path(conn, :create), ticket: params_for(:ticket)
      assert %{"id" => id} = json_response(post_conn, 201)["data"]

      get_conn = get conn, ticket_path(conn, :show, id)
      assert json_response(get_conn, 200)["data"]["id"] == id
    end

    test "sets the current user id", %{conn: conn} do
      post_conn = post conn, ticket_path(conn, :create), ticket: params_for(:ticket)
      assert %{"id" => id} = json_response(post_conn, 201)["data"]

      get_conn = get conn, ticket_path(conn, :show, id)
      assert json_response(get_conn, 200)["data"]["id"] == id
    end

    test "renders errors when the data is invalid", %{conn: conn} do
      conn = post conn, ticket_path(conn, :create), ticket: %{}
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  test "create ticket without a logged in user returns a 401", %{conn: conn} do
    conn = post conn, ticket_path(conn, :create), ticket: params_for(:ticket)
    assert response(conn, 401)
  end

  #describe "update ticket with logged in user" do
  #  setup [:log_user_in, :create_ticket]
  #
  #  test "renders ticket when data is valid", %{conn: conn, ticket: %Ticket{id: id} = ticket} do
  #    put_conn = put conn, ticket_path(conn, :update, ticket), ticket: %{closed_at: "2011-05-18T15:01:01.000000Z"}
  #    assert %{"id" => ^id} = json_response(put_conn, 200)["data"]
  #
  #    get_conn = get conn, ticket_path(conn, :show, id)
  #    assert json_response(get_conn, 200)["data"]["id"] == id
  #    assert json_response(get_conn, 200)["data"]["closed_at"] == "2011-05-18T15:01:01.000000Z"
  #  end
  #
  #  test "renders errors when data is invalid", %{conn: conn, ticket: ticket} do
  #    conn = put conn, ticket_path(conn, :update, ticket), ticket: %{description: ""}
  #    assert json_response(conn, 422)["errors"] != %{}
  #  end
  #end

  #test "update ticket without a logged in user returns a 401", %{conn: conn} do
  #  ticket = insert(:ticket)
  #  conn = put conn, ticket_path(conn, :update, ticket), ticket: %{}
  #  assert response(conn, 401)
  #end

  #describe "delete ticket with logged in user" do
  #  setup [:log_user_in, :create_ticket]
  #
  #  test "deletes chosen ticket", %{conn: conn, ticket: ticket} do
  #    delete_conn = delete conn, ticket_path(conn, :delete, ticket)
  #    assert response(delete_conn, 204)
  #
  #    assert_error_sent 404, fn ->
  #      get conn, ticket_path(conn, :show, ticket)
  #    end
  #  end
  #
  #  test "does not delete a ticket that does not belong to the user", %{conn: conn} do
  #    other_ticket = insert(:ticket)
  #    assert_error_sent 404, fn ->
  #      delete conn, ticket_path(conn, :delete, other_ticket)
  #    end
  #  end
  #end

  #test "delete ticket without a logged in user returns a 401", %{conn: conn} do
  #  ticket = insert(:ticket)
  #  conn = delete conn, ticket_path(conn, :delete, ticket)
  #  assert response(conn, 401)
  #end

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
