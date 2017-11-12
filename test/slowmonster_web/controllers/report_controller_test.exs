defmodule SlowmonsterWeb.ReportControllerTest do
  use SlowmonsterWeb.ConnCase

  import Slowmonster.Factory

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index with a logged in user" do
    setup [:log_user_in]

    test "generates a report", %{conn: conn, user: user} do
      ticket = insert(:ticket, user_id: user.id)
      insert(:time, ticket_id: ticket.id, seconds: 1)
      conn = get conn, report_path(conn, :index, ticket_ids: [ticket.id], type: "total")

      %{"tickets" => [%{"id" => id}]} = json_response(conn, 200)
      assert id == ticket.id
    end
  end

  defp log_user_in %{conn: conn} do
    user = insert(:user)
    session = insert(:session, %{user_id: user.id})

    conn = conn
    |> put_req_header("authorization", "Token token=\"#{session.token}\"")

    {:ok, conn: conn, user: user}
  end
end
