defmodule Slowmonster.Factory do
  use ExMachina.Ecto, repo: Slowmonster.Repo

  def session_factory do
    %Slowmonster.Accounts.Session{
      user_id: insert(:user).id,
      token: sequence(:token, &"token-#{&1}")
    }
  end

  def ticket_factory do
    %Slowmonster.Tickets.Ticket{
      content: "abc",
      priority: 123,
      days_in_week: 123,
      user_id: insert(:user).id
    }
  end

  def time_factory do
    %Slowmonster.Tickets.Time{
      started_at: "2010-04-17T14:00:00.000000Z",
      ticket_id: insert(:ticket).id
    }
  end

  def user_factory do
    %Slowmonster.Accounts.User{
      username: sequence(:username, &"Test User #{&1}")
    }
  end
end
