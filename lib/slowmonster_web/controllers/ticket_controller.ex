defmodule SlowmonsterWeb.TicketController do
  use SlowmonsterWeb, :controller

  alias Slowmonster.Tickets
  alias Slowmonster.Tickets.Ticket

  plug SlowmonsterWeb.Authentication

  action_fallback SlowmonsterWeb.FallbackController

  def index(conn, _params) do
    tickets = Tickets.list_tickets_for_user(conn.assigns.current_user.id)
    render(conn, "index.json", tickets: tickets)
  end

  def create(conn, %{"ticket" => ticket_params}) do
    ticket_params = Map.put(ticket_params, "user_id", conn.assigns.current_user.id)

    with {:ok, %Ticket{} = ticket} <- Tickets.create_ticket(ticket_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ticket_path(conn, :show, ticket))
      |> render("show.json", ticket: ticket)
    end
  end

  def show(conn, %{"id" => id}) do
    ticket = Tickets.get_ticket!(conn.assigns.current_user.id, id)
    render(conn, "show.json", ticket: ticket)
  end

  def update(conn, %{"id" => id, "ticket" => ticket_params}) do
    ticket = Tickets.get_ticket!(conn.assigns.current_user.id, id)

    with {:ok, %Ticket{} = ticket} <- Tickets.update_ticket(ticket, ticket_params) do
      render(conn, "show.json", ticket: ticket)
    end
  end

  def delete(conn, %{"id" => id}) do
    ticket = Tickets.get_ticket!(conn.assigns.current_user.id, id)
    with {:ok, %Ticket{}} <- Tickets.delete_ticket(ticket) do
      send_resp(conn, :no_content, "")
    end
  end
end
