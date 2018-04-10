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

      iex> list_times_for_user(%{user_id: 123, ticket_ids: %[1, 2, 3], start_time: 2001-02-03, end_time: 2001-02-04)
      [%Time{}, ...]

  """
  def list_times_for_user(%{user_id: user_id, ticket_ids: ticket_ids, start_time: start_time, end_time: end_time}) do
    Repo.all(
      from t in Time,
      join: ticket in assoc(t, :ticket),
      where: ticket.user_id == ^user_id,
      where: t.ticket_id in ^ticket_ids,
      where: t.started_at >= ^start_time,
      where: t.started_at < ^end_time
    )
  end

  @doc """
  Returns the list of times without ends.

  ## Examples

      iex> list_times_for_user %{user_id: 123, open: true}
      [%Time{}, ...]

  """
  def list_times_for_user %{user_id: user_id, open: true} do
    Repo.all(
      from t in Time,
      join: ticket in assoc(t, :ticket),
      where: is_nil(t.ended_at),
      where: ticket.user_id == ^user_id,
      order_by: t.started_at,
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

  alias Slowmonster.Tickets.Amount

  #@doc """
  #Returns the list of amounts.

  ## Examples

  #    iex> list_amounts()
  #    [%Amount{}, ...]
  #
  #"""
  #def list_amounts do
  #  Repo.all(Amount)
  #end

  @doc """
  Gets a single amount.

  Raises `Ecto.NoResultsError` if the Amount does not exist.

  ## Examples

      iex> get_amount!(789, 123)
      %Amount{}

      iex> get_amount!(789, 456)
      ** (Ecto.NoResultsError)

  """
  def get_amount!(user_id, id) do
    Repo.one!(
      from a in Amount,
      join: ticket in assoc(a, :ticket),
      where: a.id == ^id and ticket.user_id == ^user_id
    )
  end

  @doc """
  Creates a amount.

  ## Examples

      iex> create_amount(%{field: value})
      {:ok, %Amount{}}

      iex> create_amount(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_amount(attrs \\ %{}) do
    %Amount{}
    |> Amount.create_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a amount.

  ## Examples

      iex> update_amount(amount, %{field: new_value})
      {:ok, %Amount{}}

      iex> update_amount(amount, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_amount(%Amount{} = amount, attrs) do
    amount
    |> Amount.changeset(attrs)
    |> Repo.update()
  end

  #@doc """
  #Deletes a Amount.
  #
  ### Examples
  #
  #    iex> delete_amount(amount)
  #    {:ok, %Amount{}}
  #
  #    iex> delete_amount(amount)
  #    {:error, %Ecto.Changeset{}}
  #
  #"""
  #def delete_amount(%Amount{} = amount) do
  #  Repo.delete(amount)
  #end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking amount changes.

  ## Examples

      iex> change_amount(amount)
      %Ecto.Changeset{source: %Amount{}}

  """
  def change_amount(%Amount{} = amount) do
    Amount.changeset(amount, %{})
  end
end
