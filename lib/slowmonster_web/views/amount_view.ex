defmodule SlowmonsterWeb.AmountView do
  use SlowmonsterWeb, :view
  alias SlowmonsterWeb.AmountView

  def render("index.json", %{amounts: amounts}) do
    %{data: render_many(amounts, AmountView, "amount.json")}
  end

  def render("show.json", %{amount: amount}) do
    %{data: render_one(amount, AmountView, "amount.json")}
  end

  def render("amount.json", %{amount: amount}) do
    %{id: amount.id,
      amount: amount.amount,
      amounted_at: amount.amounted_at}
  end
end
