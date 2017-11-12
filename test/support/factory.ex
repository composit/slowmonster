defmodule Slowmonster.Factory do
  use ExMachina.Ecto, repo: Slowmonster.Repo

  def amount_factory do
    %Slowmonster.Tickets.Amount{
      amount: 123.4,
      amounted_at: Timex.now(),
      ticket_id: insert(:ticket).id
    }
  end

  def one_minute_time_factory do
    now = Timex.now
    %Slowmonster.Tickets.Time{
      started_at: Timex.shift(now, minutes: -1),
      ended_at: now,
      seconds: 60,
      ticket_id: insert(:ticket).id
    }
  end

  def session_factory do
    %Slowmonster.Accounts.Session{
      user_id: insert(:user).id,
      token: sequence(:token, &"token-#{&1}")
    }
  end

  def ticket_factory do
    %Slowmonster.Tickets.Ticket{
      description: "abc",
      priority: 123,
      days_in_week: 123,
      user_id: insert(:user).id
    }
  end

  def time_factory do
    %Slowmonster.Tickets.Time{
      started_at: Timex.now(),
      ticket_id: insert(:ticket).id
    }
  end

  def user_factory do
    %Slowmonster.Accounts.User{
      username: sequence(:username, &"Test User #{&1}")
    }
  end
end
