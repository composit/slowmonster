defmodule SlowmonsterWeb.ReportView do
  use SlowmonsterWeb, :view
  alias SlowmonsterWeb.ReportView

  def render("index.json", %{tickets: tickets}) do
    %{tickets: render_many(tickets, ReportView, "ticket.json")}
  end

  def render("ticket.json", %{report: %{ticket: ticket, total: total}}) do
    %{id: ticket.id,
      description: ticket.description,
      total: total}
  end

  def render("index_detail.json", %{tickets: tickets}) do
    %{tickets: render_many(tickets, ReportView, "ticket_detail.json")}
  end

  def render("ticket_detail.json", %{report: %{ticket: ticket, totals: totals}}) do
    %{id: ticket.id,
      description: ticket.description,
      totals: render_many(totals, ReportView, "total.json")}
  end

  def render("total.json", %{report: %{start_time: start_time, end_time: end_time, total: total}}) do
    %{start_time: start_time,
      end_time: end_time,
      total: total}
  end
end
