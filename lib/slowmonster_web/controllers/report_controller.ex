defmodule SlowmonsterWeb.ReportController do
  use SlowmonsterWeb, :controller

  alias Slowmonster.Reports

  plug SlowmonsterWeb.Authentication

  action_fallback SlowmonsterWeb.FallbackController

  def index(conn, %{"ticket_ids" => ticket_ids, "type" => type}) do
    tickets = Reports.report %{type: type, user_id: conn.assigns.current_user.id, ticket_ids: ticket_ids}
    render(conn, "index.json", tickets: tickets)
  end
end
