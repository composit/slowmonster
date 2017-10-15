defmodule SlowmonsterWeb.TimeView do
  use SlowmonsterWeb, :view
  alias SlowmonsterWeb.TimeView

  def render("index.json", %{times: times}) do
    %{data: render_many(times, TimeView, "time.json")}
  end

  def render("show.json", %{time: time}) do
    %{data: render_one(time, TimeView, "time.json")}
  end

  def render("time.json", %{time: time}) do
    %{id: time.id,
      started_at: time.started_at,
      ended_at: time.ended_at,
      broke_at: time.broke_at}
  end
end
