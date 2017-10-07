defmodule Slowmonster.TicketsTest do
  use Slowmonster.DataCase

  alias Slowmonster.Tickets

  describe "tickets" do
    alias Slowmonster.Tickets.Ticket

    @valid_attrs %{closed_at: "2010-04-17 14:00:00.000000Z", content: "some content", days_in_week: 120.5, priority: 42}
    @update_attrs %{closed_at: "2011-05-18 15:01:01.000000Z", content: "some updated content", days_in_week: 456.7, priority: 43}
    @invalid_attrs %{closed_at: nil, content: nil, days_in_week: nil, priority: nil}

    def ticket_fixture(attrs \\ %{}) do
      {:ok, ticket} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Tickets.create_ticket()

      ticket
    end

    test "list_tickets/0 returns all tickets" do
      ticket = ticket_fixture()
      assert Tickets.list_tickets() == [ticket]
    end

    test "get_ticket!/1 returns the ticket with given id" do
      ticket = ticket_fixture()
      assert Tickets.get_ticket!(ticket.id) == ticket
    end

    test "create_ticket/1 with valid data creates a ticket" do
      assert {:ok, %Ticket{} = ticket} = Tickets.create_ticket(@valid_attrs)
      assert ticket.closed_at == DateTime.from_naive!(~N[2010-04-17 14:00:00.000000Z], "Etc/UTC")
      assert ticket.content == "some content"
      assert ticket.days_in_week == 120.5
      assert ticket.priority == 42
    end

    test "create_ticket/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tickets.create_ticket(@invalid_attrs)
    end

    test "update_ticket/2 with valid data updates the ticket" do
      ticket = ticket_fixture()
      assert {:ok, ticket} = Tickets.update_ticket(ticket, @update_attrs)
      assert %Ticket{} = ticket
      assert ticket.closed_at == DateTime.from_naive!(~N[2011-05-18 15:01:01.000000Z], "Etc/UTC")
      assert ticket.content == "some updated content"
      assert ticket.days_in_week == 456.7
      assert ticket.priority == 43
    end

    test "update_ticket/2 with invalid data returns error changeset" do
      ticket = ticket_fixture()
      assert {:error, %Ecto.Changeset{}} = Tickets.update_ticket(ticket, @invalid_attrs)
      assert ticket == Tickets.get_ticket!(ticket.id)
    end

    test "delete_ticket/1 deletes the ticket" do
      ticket = ticket_fixture()
      assert {:ok, %Ticket{}} = Tickets.delete_ticket(ticket)
      assert_raise Ecto.NoResultsError, fn -> Tickets.get_ticket!(ticket.id) end
    end

    test "change_ticket/1 returns a ticket changeset" do
      ticket = ticket_fixture()
      assert %Ecto.Changeset{} = Tickets.change_ticket(ticket)
    end
  end
end
