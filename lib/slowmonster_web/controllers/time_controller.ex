defmodule SlowmonsterWeb.TimeController do
  use SlowmonsterWeb, :controller

  alias Slowmonster.Tickets
  alias Slowmonster.Tickets.Time

  plug SlowmonsterWeb.Authentication

  action_fallback SlowmonsterWeb.FallbackController

  def index(conn, %{"open" => open}) do
    times = Tickets.list_times_for_user(%{user_id: conn.assigns.current_user.id, open: open == "true"})

    render(conn, "index.json", times: times)
  end

  def index(conn, %{"ticket_ids" => ticket_ids_str, "start_time" => start_time, "end_time" => end_time}) do
    {:ok, start_time} = Timex.parse(start_time, "{RFC3339z}")
    {:ok, end_time} = Timex.parse(end_time, "{RFC3339z}")

    times = Tickets.list_times_for_user(%{user_id: conn.assigns.current_user.id, ticket_ids: string_to_ids(ticket_ids_str), start_time: start_time, end_time: end_time})

    render(conn, "index.json", times: times)
  end

  def create(conn, %{"time" => time_params}) do
    ticket_id = time_params["ticket_id"] || 0
    Tickets.get_ticket!(conn.assigns.current_user.id, ticket_id)

    with {:ok, %Time{} = time} <- Tickets.create_time(time_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", time_path(conn, :show, time))
      |> render("show.json", time: time)
    end
  end

  def show(conn, %{"id" => id}) do
    time = Tickets.get_time!(conn.assigns.current_user.id, id)
    render(conn, "show.json", time: time)
  end

  def update(conn, %{"id" => id, "time" => time_params}) do
    time = Tickets.get_time!(conn.assigns.current_user.id, id)
  
    with {:ok, %Time{} = time} <- Tickets.update_time(time, time_params) do
      render(conn, "show.json", time: time)
    end
  end

  def delete(conn, %{"id" => id}) do
    time = Tickets.get_time!(conn.assigns.current_user.id, id)

    with {:ok, %Time{}} <- Tickets.delete_time(time) do
      send_resp(conn, :no_content, "")
    end
  end

  defp string_to_ids(str) do
    str
    |> String.split(",")
    |> Enum.map(fn(id_str) ->
      String.to_integer(id_str)
    end)
  end
end
