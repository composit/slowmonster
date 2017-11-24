defmodule Slowmonster.ReportsTest do
  use Slowmonster.DataCase

  import Slowmonster.Factory

  alias Slowmonster.Reports

  setup do
    user = insert(:user)
    ticket = insert(:ticket, user_id: user.id)
    {:ok, user: user, ticket: ticket}
  end

  describe "unbounded totals" do
    test "report returns the total number of seconds logged for tickets", %{user: user, ticket: ticket} do
      ticket2 = insert(:ticket, user_id: user.id)

      Enum.each([ticket,ticket2], fn(ticket) ->
        insert_list(3, :one_minute_time, ticket_id: ticket.id)
      end)

      assert [%{total: 180}, %{total: 180}] = Reports.report %{type: "total", user_id: user.id, ticket_ids: [ticket.id, ticket2.id]}
    end

    test "report does not return seconds for ended tickets that do not belong to the user", %{user: user} do
      other_ticket = insert(:ticket)
      assert_raise Ecto.NoResultsError, fn -> Reports.report %{type: "total", user_id: user.id, ticket_ids: [other_ticket.id]} end
    end

    test "report returns the total number of seconds in open (un-ended) times", %{user: user, ticket: ticket} do
      insert_list(3, :time, ticket_id: ticket.id, started_at: Timex.shift(Timex.now, minutes: -1))

      assert [%{total: 180}] = Reports.report %{type: "total", user_id: user.id, ticket_ids: [ticket.id]}
    end

    test "report returns the total amounts logged for tickets", %{user: user, ticket: ticket} do
      insert_list(3, :amount, ticket_id: ticket.id, amount: 12.3, amounted_at: Timex.now)

      [%{total: total}] = Reports.report %{type: "total", user_id: user.id, ticket_ids: [ticket.id]}
      assert Float.round(total, 1) == 36.9
    end

    test "report does not return amounts for tickets that do not belong to the user", %{user: user} do
      ticket = insert(:ticket)
      insert(:amount, ticket_id: ticket.id, amount: 12.3, amounted_at: Timex.now)
      assert_raise Ecto.NoResultsError, fn -> Reports.report %{type: "total", user_id: user.id, ticket_ids: [ticket.id]} end
    end
  end

  describe "time-bounded totals" do
    test "report returns the seconds logged within a time range", %{user: user, ticket: ticket} do
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

    test "report returns the amounts logged within a time range", %{user: user, ticket: ticket} do
      end_time = Timex.beginning_of_day(Timex.now)
      insert(:amount, ticket_id: ticket.id, amount: 12.3, amounted_at: Timex.shift(end_time, days: -2, hours: 1))
      insert(:amount, ticket_id: ticket.id, amount: 23.4, amounted_at: Timex.shift(end_time, days: -2, hours: 2))
      insert(:amount, ticket_id: ticket.id, amount: 34.5, amounted_at: Timex.shift(end_time, days: -1, hours: 1))

      start_time = Timex.shift(end_time, days: -3)
      [%{ticket: t, totals: totals}] = Reports.report %{type: "daily", user_id: user.id, ticket_ids: [ticket.id], start_time: start_time, end_time: end_time}
      assert t.id == ticket.id
      assert length(totals) == 3
      assert Enum.at(totals, 0).total == 0.0
      assert Enum.at(totals, 1).total == 35.7
      assert Enum.at(totals, 2).total == 34.5
    end
  end
end
