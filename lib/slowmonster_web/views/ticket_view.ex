defmodule SlowmonsterWeb.TicketView do
  use SlowmonsterWeb, :view
  alias SlowmonsterWeb.TicketView

  def render("index.json", %{tickets: tickets}) do
    %{data: render_many(tickets, TicketView, "ticket.json")}
  end

  def render("show.json", %{ticket: ticket}) do
    %{data: render_one(ticket, TicketView, "ticket.json")}
  end

  def render("ticket.json", %{ticket: ticket}) do
    %{id: ticket.id,
      description: ticket.description,
      priority: ticket.priority,
      closed_at: ticket.closed_at,
      days_in_week: ticket.days_in_week}
  end
end
