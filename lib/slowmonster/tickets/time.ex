defmodule Slowmonster.Tickets.Time do
  use Ecto.Schema
  import Ecto.Changeset
  alias Slowmonster.Tickets.Time

  schema "times" do
    field :broke_at, :utc_datetime
    field :ended_at, :utc_datetime
    field :started_at, :utc_datetime
    belongs_to :ticket, Slowmonster.Tickets.Ticket

    timestamps()
  end

  @doc false
  def changeset(%Time{} = time, attrs) do
    time
    |> cast(attrs, [:started_at, :ended_at, :broke_at])
    |> validate_required([:started_at])
  end

  @doc false
  def create_changeset(%Time{} = time, attrs) do
    time
    |> cast(attrs, [:started_at, :ended_at, :broke_at, :ticket_id])
    |> validate_required([:started_at, :ticket_id])
  end
end
