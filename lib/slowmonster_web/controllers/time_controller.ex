defmodule SlowmonsterWeb.TimeController do
  use SlowmonsterWeb, :controller

  alias Slowmonster.Tickets
  alias Slowmonster.Tickets.Time

  plug SlowmonsterWeb.Authentication

  action_fallback SlowmonsterWeb.FallbackController

  def index(conn, _params) do
    times = Tickets.list_open_times_for_user(conn.assigns.current_user.id)
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

  #def delete(conn, %{"id" => id}) do
  #  time = Tickets.get_time!(id)
  #  with {:ok, %Time{}} <- Tickets.delete_time(time) do
  #    send_resp(conn, :no_content, "")
  #  end
  #end
end
