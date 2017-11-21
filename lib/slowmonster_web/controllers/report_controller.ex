defmodule SlowmonsterWeb.ReportController do
  use SlowmonsterWeb, :controller

  alias Slowmonster.Reports

  plug SlowmonsterWeb.Authentication

  action_fallback SlowmonsterWeb.FallbackController

  def index(conn, %{"ticket_ids" => ticket_ids_str, "type" => "total"}) do
    tickets = Reports.report %{type: "total", user_id: conn.assigns.current_user.id, ticket_ids: string_to_ids(ticket_ids_str)}
    render(conn, "index.json", tickets: tickets)
  end

  def index(conn, %{"ticket_ids" => ticket_ids_str, "type" => type, "start_time" => start_time, "end_time" => end_time}) do
    {:ok, start_time} = Timex.parse(start_time, "{RFC3339z}")
    {:ok, end_time} = Timex.parse(end_time, "{RFC3339z}")
    tickets = Reports.report %{type: type, user_id: conn.assigns.current_user.id, ticket_ids: string_to_ids(ticket_ids_str), start_time: start_time, end_time: end_time}
    render(conn, "index_detail.json", tickets: tickets)
  end

  defp string_to_ids(str) do
    str
    |> String.split(",")
    |> Enum.map(fn(id_str) ->
      String.to_integer(id_str)
    end)
  end
end
