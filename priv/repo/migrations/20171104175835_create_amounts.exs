defmodule Slowmonster.Repo.Migrations.CreateAmounts do
  use Ecto.Migration

  def change do
    create table(:amounts) do
      add :amount, :float
      add :amounted_at, :utc_datetime
      add :ticket_id, references(:tickets, on_delete: :nothing)

      timestamps()
    end

    create index(:amounts, [:ticket_id])
  end
end
