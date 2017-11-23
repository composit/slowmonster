defmodule Slowmonster.Seeder do
  alias Slowmonster.Repo
  alias Slowmonster.Accounts.{Session, User}
  alias Slowmonster.Tickets.{Amount, Ticket, Time}

  @user_id 1
  @ticket_id 1

  def seed do
    clear_all
    populate_users
    populate_tickets
    populate_times
  end

  defp clear_all do
    Enum.each [Session, Time, Amount, Ticket, User], fn(m) ->
      Repo.delete_all m
    end
  end

  defp populate_users do
    Repo.insert! %User{
      id: @user_id,
      username: "bilbo",
      password_hash: Comeonin.Bcrypt.hashpwsalt("s3cr3t")
    }
  end

  defp populate_tickets do
    Repo.insert! %Ticket{
      id: @ticket_id,
      user_id: @user_id,
      description: "good first ticket"
    }
  end

  defp populate_times do
    base_time = Timex.now
  
    Enum.each (0..364), fn(n) ->
      start_hour = Enum.random(0..23)
      start_time = Timex.shift(base_time, days: -1*n, hours: start_hour)
      end_time = Timex.shift(start_time, hours: 5)
      seconds = DateTime.diff(end_time, start_time, :seconds)
  
      Repo.insert! %Time{
        id: n,
        ticket_id: @ticket_id,
        started_at: start_time,
        ended_at: end_time,
        seconds: seconds
      }
    end
  end
end
