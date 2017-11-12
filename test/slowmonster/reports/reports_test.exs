defmodule Slowmonster.ReportsTest do
  use Slowmonster.DataCase

  import Slowmonster.Factory

  alias Slowmonster.Reports

  describe "totals" do
    test "total_ended_seconds/2 returns the total number of seconds for a set of tickets" do
      user = insert(:user)
      t1 = insert(:ticket, user_id: user.id)
      t2 = insert(:ticket, user_id: user.id)
      t3 = insert(:ticket, user_id: user.id)

      Enum.each([t1,t2,t3], fn(ticket) ->
        insert_list(3, :one_minute_time, ticket_id: ticket.id)
      end)

      assert Reports.total_ended_seconds(user.id, [t1.id, t3.id]) == 360
    end

    test "total_ended_seconds/2 does not return seconds for tickets that do not belong to the user" do
      user = insert(:user)
      t1 = insert(:ticket, user_id: user.id)
      t2 = insert(:ticket)

      Enum.each([t1,t2], fn(ticket) ->
        insert_list(3, :one_minute_time, ticket_id: ticket.id)
      end)

      assert Reports.total_ended_seconds(user.id, [t1.id, t2.id]) == 180
    end

    test "total_unended_seconds/2 returns the total number of seconds in open (un-ended) times" do
      user = insert(:user)
      ticket = insert(:ticket, user_id: user.id)

      now = Timex.now
      insert_list(3, :time, ticket_id: ticket.id, started_at: Timex.shift(now, minutes: -1))

      assert Reports.total_unended_seconds(user.id, [ticket.id], now) == 180
    end

    test "total_unended_seconds/2 does not return seconds for tickets that do not belong to the user" do
      user = insert(:user)
      t1 = insert(:ticket, user_id: user.id)
      t2 = insert(:ticket)

      now = Timex.now
      Enum.each([t1,t2], fn(ticket) ->
        insert_list(3, :time, ticket_id: ticket.id, started_at: Timex.shift(now, minutes: -1))
      end)

      assert Reports.total_unended_seconds(user.id, [t1.id, t2.id], now) == 180
    end
  end
end
