defmodule Slowmonster.Tickets.Amount do
  use Ecto.Schema
  import Ecto.Changeset
  alias Slowmonster.Tickets.Amount


  schema "amounts" do
    field :amount, :float
    field :amounted_at, :utc_datetime
    belongs_to :ticket, Slowmonster.Tickets.Ticket

    timestamps()
  end

  @doc false
  def changeset(%Amount{} = amount, attrs) do
    amount
    |> cast(attrs, [:amount, :amounted_at])
    |> validate_required([:amount, :amounted_at])
  end

  @doc false
  def create_changeset(%Amount{} = amount, attrs) do
    amount
    |> cast(attrs, [:amount, :amounted_at, :ticket_id])
    |> validate_required([:amount, :amounted_at, :ticket_id])
  end
end
