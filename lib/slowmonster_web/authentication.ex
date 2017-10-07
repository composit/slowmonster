defmodule SlowmonsterWeb.Authentication do
  import Plug.Conn

  alias Slowmonster.Accounts

  def init(options), do: options

  def call(conn, _opts) do
    case find_user(conn) do
      {:ok, user} -> assign(conn, :current_user, user)
      _otherwise  -> auth_error!(conn)
    end
  end

  defp find_user(conn) do
    with auth_header = get_req_header(conn, "authorization"),
      {:ok, token}   <- parse_token(auth_header),
      {:ok, session} <- find_session_by_token(token),
    do: find_user_by_session(session)
  end

  defp parse_token(["Token token=" <> token]) do
    {:ok, String.replace(token, "\"", "")}
  end
  defp parse_token(_non_token_header), do: :error

  defp find_session_by_token(token) do
    case Accounts.find_session_by_token(token) do
      nil     -> :error
      session -> {:ok, session}
    end
  end

  defp find_user_by_session(session) do
    {:ok, Accounts.get_user!(session.user_id)}
  end

  defp auth_error!(conn) do
    conn
    |> send_resp(:unauthorized, "")
    |> halt()
  end
end
