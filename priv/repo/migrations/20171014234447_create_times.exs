defmodule Slowmonster.Repo.Migrations.CreateTimes do
  use Ecto.Migration

  def change do
    create table(:times) do
      add :started_at, :utc_datetime
      add :broke_at, :utc_datetime
      add :ended_at, :utc_datetime
      add :ticket_id, references(:tickets, on_delete: :nothing)

      timestamps()
    end

    create index(:times, [:ticket_id])
  end
end
