require IEx
defmodule SlowmonsterWeb.SessionController do
  use SlowmonsterWeb, :controller

  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]

  alias Slowmonster.Accounts
  alias Slowmonster.Accounts.Session

  def create(conn, %{"user" => user_params}) do
    user = Accounts.get_user_by_email(user_params["email"])
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
end
