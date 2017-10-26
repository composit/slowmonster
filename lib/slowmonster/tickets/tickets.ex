require IEx
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

      iex> list_tickets_for_user(123)
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

      iex> list_times_for_user(user_id)
      [%Time{}, ...]

  """
  def list_times_for_user(user_id) do
    Repo.all(
      from t in Time,
      join: ticket in assoc(t, :ticket),
      where: ticket.user_id == ^user_id
    )
  end

  @doc """
  Returns the list of times without ends.

  ## Examples

      iex> list_open_times_for_user(user_id)
      [%Time{}, ...]

  """
  def list_open_times_for_user(user_id) do
    Repo.all(
      from t in Time,
      join: ticket in assoc(t, :ticket),
      where: is_nil(t.ended_at),
      where: ticket.user_id == ^user_id,
      preload: [:ticket]
    )
  end

  @doc """
  Gets a single time.

  Raises `Ecto.NoResultsError` if the Time does not exist.

  ## Examples

      iex> get_time!(789, 123)
      %Time{}

      iex> get_time!(789, 456)
      ** (Ecto.NoResultsError)

  """
  def get_time!(user_id, id) do
    Repo.one!(
      from t in Time,
      join: ticket in assoc(t, :ticket),
      where: t.id == ^id and ticket.user_id == ^user_id,
      preload: [:ticket]
    )
  end

  @doc """
  Creates a time.

  ## Examples

      iex> create_time(%{field: value})
      {:ok, %Time{}}

      iex> create_time(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_time(attrs \\ %{}) do
    case %Time{}
    |> Time.create_changeset(attrs)
    |> Repo.insert() do
      {:ok, %Time{} = time} ->
        time = Repo.preload(time, :ticket)
        {:ok, time}
      {:error, time} ->
        {:error, time}
    end
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
    case time
    |> Time.changeset(attrs)
    |> Repo.update() do
      {:ok, %Time{} = updated_time} ->
        updated_time = Repo.preload(updated_time, :ticket)
        {:ok, updated_time}
      {:error, updated_time} ->
        {:error, updated_time}
    end
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
