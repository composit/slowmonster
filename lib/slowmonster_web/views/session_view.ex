defmodule SlowmonsterWeb.SessionView do
  use SlowmonsterWeb, :view

  def render("show.json", %{session: session}) do
    %{data: render_one(session, SlowmonsterWeb.SessionView, "session.json")}
  end

  def render("session.json", %{session: session}) do
    %{token: session.token}
  end

  def render("error.json", _anything) do
    %{errors: "failed to authenticate"}
  end

  def render("test.json", %{user: user}) do
    %{username: user.username, success: true}
  end
end
