defmodule Slowmonster.Factory do
  use ExMachina.Ecto, repo: Slowmonster.Repo

  def user_factory do
    %Slowmonster.Accounts.User{
      username: "Test User"
    }
  end

  def ticket_factory do
    %Slowmonster.Tickets.Ticket{}
  end
end
