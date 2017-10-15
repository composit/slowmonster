defmodule Slowmonster.Tickets do
  @moduledoc """
  The Tickets context.
  """

  import Ecto.Query, warn: false
  alias Slowmonster.Repo

  alias Slowmonster.Tickets.Ticket

  @doc """
  Returns the list of tickets for a user.

  ## Examples

      iex> list_tickets_by_user(123)
      [%Ticket{}, ...]

  """
  def list_tickets_for_user(user_id) do
    Ticket
    |> where(user_id: ^user_id)
    |> Repo.all
  end

  @doc """
  Gets a single ticket.

  Raises `Ecto.NoResultsError` if the Ticket does not exist.

  ## Examples

      iex> get_ticket!(789, 123)
      %Ticket{}

      iex> get_ticket!(456)
      ** (Ecto.NoResultsError)

  """
  def get_ticket!(user_id, id), do: Repo.get_by!(Ticket, id: id, user_id: user_id)

  @doc """
  Creates a ticket.

  ## Examples

      iex> create_ticket(%{field: value})
      {:ok, %Ticket{}}

      iex> create_ticket(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_ticket(attrs \\ %{}) do
    %Ticket{}
    |> Ticket.create_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a ticket.

  ## Examples

      iex> update_ticket(ticket, %{field: new_value})
      {:ok, %Ticket{}}

      iex> update_ticket(ticket, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_ticket(%Ticket{} = ticket, attrs) do
    ticket
    |> Ticket.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Ticket.

  ## Examples

      iex> delete_ticket(ticket)
      {:ok, %Ticket{}}

      iex> delete_ticket(ticket)
      {:error, %Ecto.Changeset{}}

  """
  def delete_ticket(%Ticket{} = ticket) do
    Repo.delete(ticket)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking ticket changes.

  ## Examples

      iex> change_ticket(ticket)
      %Ecto.Changeset{source: %Ticket{}}

  """
  def change_ticket(%Ticket{} = ticket) do
    Ticket.changeset(ticket, %{})
  end

  alias Slowmonster.Tickets.Time

  @doc """
  Returns the list of times.

  ## Examples

      iex> list_times()
      [%Time{}, ...]

  """
  def list_times do
    Repo.all(Time)
  end

  @doc """
  Gets a single time.

  Raises `Ecto.NoResultsError` if the Time does not exist.

  ## Examples

      iex> get_time!(123)
      %Time{}

      iex> get_time!(456)
      ** (Ecto.NoResultsError)

  """
  def get_time!(id), do: Repo.get!(Time, id)

  @doc """
  Creates a time.

  ## Examples

      iex> create_time(%{field: value})
      {:ok, %Time{}}

      iex> create_time(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_time(attrs \\ %{}) do
    %Time{}
    |> Time.create_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a time.

  ## Examples

      iex> update_time(time, %{field: new_value})
      {:ok, %Time{}}

      iex> update_time(time, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_time(%Time{} = time, attrs) do
    time
    |> Time.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Time.

  ## Examples

      iex> delete_time(time)
      {:ok, %Time{}}

      iex> delete_time(time)
      {:error, %Ecto.Changeset{}}

  """
  def delete_time(%Time{} = time) do
    Repo.delete(time)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking time changes.

  ## Examples

      iex> change_time(time)
      %Ecto.Changeset{source: %Time{}}

  """
  def change_time(%Time{} = time) do
    Time.changeset(time, %{})
  end
end
