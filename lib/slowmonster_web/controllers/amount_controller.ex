defmodule SlowmonsterWeb.AmountController do
  use SlowmonsterWeb, :controller

  alias Slowmonster.Tickets
  alias Slowmonster.Tickets.Amount

  plug SlowmonsterWeb.Authentication

  action_fallback SlowmonsterWeb.FallbackController

  def index(conn, %{"ticket_ids" => ticket_ids_str, "start_time" => start_time, "end_time" => end_time}) do
    {:ok, start_time} = Timex.parse(start_time, "{RFC3339z}")
    {:ok, end_time} = Timex.parse(end_time, "{RFC3339z}")

    amounts = Tickets.list_amounts_for_user(%{user_id: conn.assigns.current_user.id, ticket_ids: string_to_ids(ticket_ids_str), start_time: start_time, end_time: end_time})

    render(conn, "index.json", amounts: amounts)
  end

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

  def delete(conn, %{"id" => id}) do
    amount = Tickets.get_amount!(conn.assigns.current_user.id, id)

    with {:ok, %Amount{}} <- Tickets.delete_amount(amount) do
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
