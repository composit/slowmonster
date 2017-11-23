defmodule Slowmonster.Reports do
  @moduledoc """
  The Reports context.
  """

  import Ecto.Query, warn: false

  alias Slowmonster.Repo
  alias Slowmonster.Tickets
  alias Slowmonster.Tickets.Time

  @doc """
  Runs a "totals" (i.e. not time-bound) report for one or more tickets
  """
  def report %{type: "total", user_id: user_id, ticket_ids: ticket_ids} do
    Enum.map(ticket_ids, fn(ticket_id) ->
      ticket = Tickets.get_ticket!(user_id, ticket_id)
      tes = total_ended_seconds(user_id, [ticket_id]) || 0
      tus = total_unended_seconds(user_id, [ticket_id], Timex.now) || 0
      %{ticket: ticket, total: tes + tus}
    end)
  end

  @doc """
  Returns the total number of seconds logged for the given tickets
  within the specified start and end times
  """
  def report %{type: type, user_id: user_id, ticket_ids: ticket_ids, start_time: start_time, end_time: end_time} do
    interval = case type do
      "daily" ->
        60*60*24
      "weekly" ->
        60*60*24*7
    end

    Enum.map(ticket_ids, fn(ticket_id) ->
      ticket = Tickets.get_ticket!(user_id, ticket_id)
      totals = interval_seconds([], user_id, ticket_ids, start_time, end_time, interval)
      %{ticket: ticket, totals: totals}
    end)
  end

  defp total_ended_seconds(user_id, ticket_ids) do
    seconds = Repo.all(
      from t in Time,
      join: ticket in assoc(t, :ticket),
      select: sum(t.seconds),
      where: not is_nil(t.ended_at),
      where: ticket.user_id == ^user_id,
      where: t.ticket_id in ^ticket_ids
    )

    List.first(seconds)
  end

  defp total_unended_seconds(user_id, ticket_ids, current_time) do
    times = Repo.all(
      from t in Time,
      join: ticket in assoc(t, :ticket),
      where: is_nil(t.ended_at),
      where: ticket.user_id == ^user_id,
      where: t.ticket_id in ^ticket_ids
    )

    Enum.reduce(times, 0, fn(time, seconds) ->
      seconds + DateTime.diff(current_time, time.started_at)
    end)
  end

  defp interval_seconds(totals, user_id, ticket_ids, start_time, end_time, interval) do
    interval_end = Timex.shift(start_time, seconds: interval)
    tesw = total_ended_seconds_within(user_id, ticket_ids, start_time, interval_end) || 0
    tsa = total_seconds_around(user_id, ticket_ids, start_time, interval_end, Timex.now) || 0
    totals = totals ++ [%{start_time: start_time, end_time: interval_end, total: tesw + tsa}]
    if DateTime.compare(interval_end, end_time) == :lt do
      interval_seconds(totals, user_id, ticket_ids, interval_end, end_time, interval)
    else
      totals
    end
  end

  defp total_ended_seconds_within(user_id, ticket_ids, start_time, end_time) do
    seconds = Repo.all(
      from t in Time,
      join: ticket in assoc(t, :ticket),
      select: sum(t.seconds),
      where: not is_nil(t.ended_at),
      where: ticket.user_id == ^user_id,
      where: t.ticket_id in ^ticket_ids,
      where: t.started_at >= ^start_time,
      where: t.ended_at < ^end_time
    )

    List.first(seconds)
  end

  defp total_seconds_around(user_id, ticket_ids, start_time, end_time, current_time) do
    times = Repo.all(
      from t in Time,
      join: ticket in assoc(t, :ticket),
      where: ticket.user_id == ^user_id,
      where: t.ticket_id in ^ticket_ids,
      where: (t.started_at <= ^start_time and t.ended_at > ^start_time) or
             (t.started_at <= ^end_time and t.ended_at > ^end_time) or
             (t.started_at <= ^end_time and is_nil(t.ended_at))
    )

    Enum.reduce(times, 0, fn(time, seconds) ->
      started = if time.started_at < start_time do
        start_time
      else
        time.started_at
      end

      ended = if time.ended_at >= end_time or is_nil(time.ended_at) do
        end_time
      else
        time.ended_at
      end

      seconds + DateTime.diff(ended, started)
    end)
  end
end
