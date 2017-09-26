defmodule SlowmonsterWeb.SessionController do
  use SlowmonsterWeb, :controller

  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]

  alias Slowmonster.Accounts
  alias Slowmonster.Accounts.Session

  plug SlowmonsterWeb.Authentication when action in [:index]

  def create(conn, %{"user" => user_params}) do
    user = Accounts.get_user_by_username(user_params["username"])
    cond do
      user && checkpw(user_params["password"], user.password_hash) ->
        {:ok, %Session{} = session} = Accounts.create_session(%{user_id: user.id})
        conn
        |> put_status(:created)
        |> put_resp_header("location", user_path(conn, :show, user))
        |> render("show.json", session: session)
      user ->
        conn
        |> put_status(:unauthorized)
        |> render("error.json", user_params)
      true ->
        dummy_checkpw()
        conn
        |> put_status(:unauthorized)
        |> render("error.json", user_params)
    end
  end

  # temporary for testing sessions, remove route when done
  def index(conn, _params) do
    if user = conn.assigns.current_user do
      render(conn, "test.json", user: user)
    else
      render(conn, "error.json", "")
    end
  end
end
