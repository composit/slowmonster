defmodule Slowmonster.ReportsTest do
  use Slowmonster.DataCase

  import Slowmonster.Factory

  alias Slowmonster.Reports

  describe "unbounded totals" do
    test "report returns the total number of seconds logged for tickets" do
      user = insert(:user)
      t1 = insert(:ticket, user_id: user.id)
      t2 = insert(:ticket, user_id: user.id)

      Enum.each([t1,t2], fn(ticket) ->
        insert_list(3, :one_minute_time, ticket_id: ticket.id)
      end)

      assert [%{total: 180}, %{total: 180}] = Reports.report %{type: "total", user_id: user.id, ticket_ids: [t1.id, t2.id]}
    end

    test "report does not return seconds for ended tickets that do not belong to the user" do
      user = insert(:user)
      ticket = insert(:ticket)
      assert_raise Ecto.NoResultsError, fn -> Reports.report %{type: "total", user_id: user.id, ticket_ids: [ticket.id]} end
    end

    test "report returns the total number of seconds in open (un-ended) times" do
      user = insert(:user)
      ticket = insert(:ticket, user_id: user.id)

      insert_list(3, :time, ticket_id: ticket.id, started_at: Timex.shift(Timex.now, minutes: -1))

      assert [%{total: 180}] = Reports.report %{type: "total", user_id: user.id, ticket_ids: [ticket.id]}
    end
  end

  describe "time-bounded totals" do
    test "total_ended_seconds_within/4 returns the seconds logged within a time range" do
      user = insert(:user)
      ticket = insert(:ticket, user_id: user.id)
      end_time = Timex.beginning_of_day(Timex.now)
      # within day 2
      insert(:time, ticket_id: ticket.id, started_at: Timex.shift(end_time, days: -2, hours: 1), ended_at: Timex.shift(end_time, days: -2, hours: 2), seconds: 3600)
      # day 1-2
      insert(:time, ticket_id: ticket.id, started_at: Timex.shift(end_time, days: -2, hours: -1), ended_at: Timex.shift(end_time, days: -2, hours: 1), seconds: 7200)
      # day 2-3
      insert(:time, ticket_id: ticket.id, started_at: Timex.shift(end_time, days: -1, hours: -1), ended_at: Timex.shift(end_time, days: -1, hours: 1), seconds: 7200)
      # day 3, unended
      insert(:time, ticket_id: ticket.id, started_at: Timex.shift(end_time, hours: -1))

      start_time = Timex.shift(end_time, days: -3)
      [%{ticket: t, totals: totals}] = Reports.report %{type: "daily", user_id: user.id, ticket_ids: [ticket.id], start_time: start_time, end_time: end_time}
      assert t.id == ticket.id
      assert length(totals) == 3
      assert Enum.at(totals, 0).total == 3600
      assert Enum.at(totals, 1).total == 10800
      assert Enum.at(totals, 2).total == 7200
    end
  end
end
