defmodule Slowmonster.TicketsTest do
  use Slowmonster.DataCase

  import Slowmonster.Factory

  alias Slowmonster.Tickets

  describe "tickets" do
    alias Slowmonster.Tickets.Ticket

    test "list_tickets_by_user/1 returns all tickets for a user" do
      user = insert(:user)
      ticket_one = insert(:ticket, %{user_id: user.id})
      ticket_two = insert(:ticket, %{user_id: user.id})
      assert Tickets.list_tickets_for_user(user.id) == [ticket_two, ticket_one]
    end

    test "list_tickets_by_user/1 does not return tickets for a different user" do
      user = insert(:user)
      insert(:ticket)
      assert Tickets.list_tickets_for_user(user.id) == []
    end

    test "get_ticket!/2 returns the ticket with given id and user id" do
      user = insert(:user)
      ticket = insert(:ticket, %{user_id: user.id})
      assert Tickets.get_ticket!(user.id, ticket.id) == ticket
    end

    test "get_ticket!/2 returns no ticket if the user id does not exist" do
      user = insert(:user)
      ticket = insert(:ticket)
      assert_raise Ecto.NoResultsError, fn -> Tickets.get_ticket!(user.id, ticket.id) == nil end
    end

    test "create_ticket/1 with valid data creates a ticket" do
      assert {:ok, %Ticket{} = _} = Tickets.create_ticket(params_for(:ticket))
    end

    test "create_ticket/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tickets.create_ticket(%{})
    end

    test "update_ticket/2 with valid data updates the ticket" do
      ticket = insert(:ticket)
      assert {:ok, ticket} = Tickets.update_ticket(ticket, %{closed_at: "2011-05-18 15:01:01.000000Z"})
      assert %Ticket{} = ticket
      assert ticket.closed_at == DateTime.from_naive!(~N[2011-05-18 15:01:01.000000Z], "Etc/UTC")
    end

    test "update_ticket/2 with invalid data returns error changeset" do
      user = insert(:user)
      ticket = insert(:ticket, %{user_id: user.id})
      assert {:error, %Ecto.Changeset{}} = Tickets.update_ticket(ticket, %{description: ""})
      assert ticket == Tickets.get_ticket!(user.id, ticket.id)
    end

    test "delete_ticket/1 deletes the ticket" do
      user = insert(:user)
      ticket = insert(:ticket, %{user_id: user.id})
      assert {:ok, %Ticket{}} = Tickets.delete_ticket(ticket)
      assert_raise Ecto.NoResultsError, fn -> Tickets.get_ticket!(user.id, ticket.id) end
    end

    test "change_ticket/1 returns a ticket changeset" do
      ticket = insert(:ticket)
      assert %Ecto.Changeset{} = Tickets.change_ticket(ticket)
    end
  end

  describe "times" do
    alias Slowmonster.Tickets.Time

    test "list_times/0 returns all times" do
      time = insert(:time)
      assert Tickets.list_times() == [time]
    end

    test "get_time!/1 returns the time with given id" do
      time = insert(:time)
      assert Tickets.get_time!(time.id) == time
    end

    test "create_time/1 with valid data creates a time" do
      assert {:ok, %Time{} = time} = Tickets.create_time(params_for(:time))
      assert time.ticket_id != nil
    end

    test "create_time/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tickets.create_time(%{})
    end

    test "update_time/2 with valid data updates the time" do
      time = insert(:time)
      assert {:ok, time} = Tickets.update_time(time, %{ended_at: "2011-05-18T15:01:01.000000Z"})
      assert %Time{} = time
      assert time.ended_at == DateTime.from_naive!(~N[2011-05-18 15:01:01.000000Z], "Etc/UTC")
    end

    test "update_time/2 with invalid data returns error changeset" do
      time = insert(:time)
      assert {:error, %Ecto.Changeset{}} = Tickets.update_time(time, %{started_at: "abc"})
      assert time == Tickets.get_time!(time.id)
    end

    test "delete_time/1 deletes the time" do
      time = insert(:time)
      assert {:ok, %Time{}} = Tickets.delete_time(time)
      assert_raise Ecto.NoResultsError, fn -> Tickets.get_time!(time.id) end
    end

    test "change_time/1 returns a time changeset" do
      time = insert(:time)
      assert %Ecto.Changeset{} = Tickets.change_time(time)
    end
  end
end
