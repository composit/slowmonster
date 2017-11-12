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
  Returns the total number of seconds logged for the tickets
  ticket_ids is an array because of child tickets
  """
  def total_ended_seconds(user_id, ticket_ids) do
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

  @doc """
  Returns the total number of seconds in current open (un-ended) times
  sums the number of seconds between the started_at time and the current time
  """
  def total_unended_seconds(user_id, ticket_ids, end_time) do
    times = Repo.all(
      from t in Time,
      join: ticket in assoc(t, :ticket),
      where: is_nil(t.ended_at),
      where: ticket.user_id == ^user_id,
      where: t.ticket_id in ^ticket_ids
    )

    Enum.reduce(times, 0, fn(time, seconds) ->
      seconds + Elixir.Time.diff(end_time, time.started_at)
    end)
  end
end
