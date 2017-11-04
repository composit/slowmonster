defmodule SlowmonsterWeb.AmountController do
  use SlowmonsterWeb, :controller

  alias Slowmonster.Tickets
  alias Slowmonster.Tickets.Amount

  plug SlowmonsterWeb.Authentication

  action_fallback SlowmonsterWeb.FallbackController

  def create(conn, %{"amount" => amount_params}) do
    ticket_id = amount_params["ticket_id"] || 0
    Tickets.get_ticket!(conn.assigns.current_user.id, ticket_id)

    with {:ok, %Amount{} = amount} <- Tickets.create_amount(amount_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", amount_path(conn, :show, amount))
      |> render("show.json", amount: amount)
    end
  end

  def show(conn, %{"id" => id}) do
    amount = Tickets.get_amount!(conn.assigns.current_user.id, id)
    render(conn, "show.json", amount: amount)
  end

  def update(conn, %{"id" => id, "amount" => amount_params}) do
    amount = Tickets.get_amount!(conn.assigns.current_user.id, id)

    with {:ok, %Amount{} = amount} <- Tickets.update_amount(amount, amount_params) do
      render(conn, "show.json", amount: amount)
    end
  end

  #def delete(conn, %{"id" => id}) do
  #  amount = Tickets.get_amount!(id)
  #  with {:ok, %Amount{}} <- Tickets.delete_amount(amount) do
  #    send_resp(conn, :no_content, "")
  #  end
  #end
end
