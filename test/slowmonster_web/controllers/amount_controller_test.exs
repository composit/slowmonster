defmodule SlowmonsterWeb.AmountControllerTest do
  use SlowmonsterWeb.ConnCase

  import Slowmonster.Factory

  alias Slowmonster.Tickets.Amount

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create amount with logged in user" do
    setup [:log_user_in, :create_ticket]

    test "renders amount when data is valid", %{conn: conn, ticket: ticket} do
      amount_params = Map.put(params_for(:amount), :ticket_id, ticket.id)
      post_conn = post conn, amount_path(conn, :create), amount: amount_params
      assert %{"id" => id} = json_response(post_conn, 201)["data"]

      get_conn = get conn, amount_path(conn, :show, id)
      assert json_response(get_conn, 200)["data"]["id"] == id
    end

    test "renders errors when data is invalid", %{conn: conn, ticket: ticket} do
      conn = post conn, amount_path(conn, :create), amount: %{ticket_id: ticket.id}
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when the user does not own the ticket", %{conn: conn} do
      assert_raise Ecto.NoResultsError, fn ->
        post conn, amount_path(conn, :create), amount: params_for(:amount)
      end
    end
  end

  test "create amount without a logged in user returns a 401", %{conn: conn} do
    conn = post conn, amount_path(conn, :create), amount: params_for(:amount)
    assert response(conn, 401)
  end

  describe "update amount with a logged in user" do
    setup [:log_user_in, :create_amount]

    test "renders amount when data is valid", %{conn: conn, amount: %Amount{id: id} = amount} do
      put_conn = put conn, amount_path(conn, :update, amount), amount: %{amount: 456}
      assert %{"id" => ^id} = json_response(put_conn, 200)["data"]

      get_conn = get conn, amount_path(conn, :show, id)
      assert json_response(get_conn, 200)["data"]["amount"] == 456
    end

    test "renders errors when the user does not own the amount", %{conn: conn} do
      amount = insert(:amount)
      assert_raise Ecto.NoResultsError, fn ->
        put conn, amount_path(conn, :update, amount), amount: %{amount: 456}
      end
    end

    test "renders errors when data is invalid", %{conn: conn, amount: amount} do
      conn = put conn, amount_path(conn, :update, amount), amount: %{amount: "abc"}
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  #describe "delete amount" do
  #  setup [:create_amount]
  #
  #  test "deletes chosen amount", %{conn: conn, amount: amount} do
  #    conn = delete conn, amount_path(conn, :delete, amount)
  #    assert response(conn, 204)
  #    assert_error_sent 404, fn ->
  #      get conn, amount_path(conn, :show, amount)
  #    end
  #  end
  #end

  defp create_amount %{user: user} do
    {:ok, ticket: ticket} = create_ticket %{user: user}
    amount = insert(:amount, ticket_id: ticket.id)
    {:ok, amount: amount, ticket: ticket}
  end

  defp create_ticket %{user: user} do
    ticket = insert(:ticket, user_id: user.id)
    {:ok, ticket: ticket}
  end

  defp log_user_in %{conn: conn} do
    user = insert(:user)
    session = insert(:session, %{user_id: user.id})

    conn = conn
    |> put_req_header("accept", "application/json")
    |> put_req_header("authorization", "Token token=\"#{session.token}\"")

    {:ok, conn: conn, user: user}
  end
end
