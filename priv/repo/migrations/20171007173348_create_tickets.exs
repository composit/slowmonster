defmodule Slowmonster.Repo.Migrations.CreateTickets do
  use Ecto.Migration

  def change do
    create table(:tickets) do
      add :content, :string
      add :priority, :integer
      add :closed_at, :utc_datetime
      add :days_in_week, :float
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:tickets, [:user_id])
  end
end
