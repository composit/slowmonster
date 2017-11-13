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

    test "generates a daily detail report", %{conn: conn, user: user} do
      ticket = insert(:ticket, user_id: user.id)
      now = Timex.now
      insert(:time, ticket_id: ticket.id, seconds: 1, started_at: Timex.shift(now, seconds: -1), ended_at: now)
      insert(:time, ticket_id: ticket.id, seconds: 1, started_at: Timex.shift(now, days: -1, seconds: -1), ended_at: Timex.shift(now, days: -1))

      {:ok, start_time} = Timex.format(Timex.shift(now, days: -2), "{RFC3339z}")
      {:ok, end_time} = Timex.format(now, "{RFC3339z}")
      conn = get conn, report_path(conn, :index, ticket_ids: [ticket.id], type: "daily", start_time: start_time, end_time: end_time)
      %{"tickets" => [%{"totals" => times}]} = json_response(conn, 200)
      assert length(times) == 2
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
