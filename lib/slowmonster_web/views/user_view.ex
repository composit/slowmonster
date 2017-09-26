defmodule SlowmonsterWeb.UserView do
  use SlowmonsterWeb, :view
  alias SlowmonsterWeb.UserView

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{id: user.id,
      username: user.username}
  end
end
