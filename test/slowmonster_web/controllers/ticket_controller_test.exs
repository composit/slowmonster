defmodule SlowmonsterWeb.TicketControllerTest do
  use SlowmonsterWeb.ConnCase

  import Slowmonster.Factory

  alias Slowmonster.Tickets
  alias Slowmonster.Tickets.Ticket

  @create_attrs %{closed_at: "2010-04-17T14:00:00.000000Z", content: "some content", days_in_week: 120.5, priority: 42}
  @update_attrs %{closed_at: "2011-05-18T15:01:01.000000Z", content: "some updated content", days_in_week: 456.7, priority: 43}
  @invalid_attrs %{closed_at: nil, content: nil, days_in_week: nil, priority: nil}

  def fixture(:ticket) do
    {:ok, ticket} = Tickets.create_ticket(@create_attrs)
    ticket
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index with a logged in user" do
    setup [:log_user_in]

    test "lists all tickets belonging to that user", %{conn: conn, user: user} do
      conn = get conn, ticket_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end

    test "does not list tickets not belonging to that user", %{conn: conn} do
      conn = get conn, ticket_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  test "index without a logged in user returns a 401", %{conn: conn} do
    conn = get conn, ticket_path(conn, :index)
    assert json_response(conn, 401)
  end

  describe "create ticket" do
    test "renders ticket when logged in and the data is valid", %{conn: conn} do
      conn = post conn, ticket_path(conn, :create), ticket: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, ticket_path(conn, :show, id)
      assert json_response(conn, 200)["data"]["id"] == id
    end

    test "renders errors when logged in and the data is invalid", %{conn: conn} do
      conn = post conn, ticket_path(conn, :create), ticket: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update ticket" do
    setup [:create_ticket]

    test "renders ticket when data is valid", %{conn: conn, ticket: %Ticket{id: id} = ticket} do
      conn = put conn, ticket_path(conn, :update, ticket), ticket: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, ticket_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "closed_at" => "2011-05-18T15:01:01.000000Z",
        "content" => "some updated content",
        "days_in_week" => 456.7,
        "priority" => 43}
    end

    test "renders errors when data is invalid", %{conn: conn, ticket: ticket} do
      conn = put conn, ticket_path(conn, :update, ticket), ticket: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete ticket" do
    setup [:create_ticket]

    test "deletes chosen ticket", %{conn: conn, ticket: ticket} do
      conn = delete conn, ticket_path(conn, :delete, ticket)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, ticket_path(conn, :show, ticket)
      end
    end
  end

  defp create_ticket(_) do
    ticket = fixture(:ticket)
    {:ok, ticket: ticket}
  end

  defp log_user_in %{conn: conn} do
    user = build(:user)
    conn = assign(conn, :current_user, user)
    {:ok, user: user}
  end
end
