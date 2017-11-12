defmodule Slowmonster.Tickets.Time do
  use Ecto.Schema
  import Ecto.Changeset
  alias Slowmonster.Tickets.Time

  schema "times" do
    field :broke_at, :utc_datetime
    field :ended_at, :utc_datetime
    field :started_at, :utc_datetime
    field :seconds, :integer
    belongs_to :ticket, Slowmonster.Tickets.Ticket

    timestamps()
  end

  @doc false
  def changeset(%Time{} = time, attrs) do
    time
    |> cast(attrs, [:started_at, :ended_at, :broke_at, :seconds])
    |> generate_seconds()
    |> validate_required([:started_at])
  end

  @doc false
  def create_changeset(%Time{} = time, attrs) do
    time
    |> cast(attrs, [:started_at, :ended_at, :broke_at, :ticket_id, :seconds])
    |> generate_seconds()
    |> validate_required([:started_at, :ticket_id])
  end

  defp generate_seconds(changeset) do
    started_at = get_field(changeset, :started_at)
    ended_at = get_field(changeset, :ended_at)
    seconds = if started_at && ended_at do
      DateTime.diff(ended_at, started_at, :seconds)
    end
    put_change(changeset, :seconds, seconds)
  end
end
