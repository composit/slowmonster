defmodule Slowmonster.Tickets.Ticket do
  use Ecto.Schema
  import Ecto.Changeset
  alias Slowmonster.Tickets.Ticket


  schema "tickets" do
    field :closed_at, :utc_datetime
    field :content, :string
    field :days_in_week, :float
    field :priority, :integer
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(%Ticket{} = ticket, attrs) do
    ticket
    |> cast(attrs, [:content, :priority, :closed_at, :days_in_week])
    |> validate_required([:content, :priority, :days_in_week, :user_id])
  end

  @doc false
  def create_changeset(%Ticket{} = ticket, attrs) do
    ticket
    |> cast(attrs, [:content, :priority, :closed_at, :days_in_week, :user_id])
    |> validate_required([:content, :priority, :days_in_week, :user_id])
  end
end
