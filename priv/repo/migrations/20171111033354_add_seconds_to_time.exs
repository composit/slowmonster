defmodule Slowmonster.Repo.Migrations.AddMinutesToTime do
  use Ecto.Migration

  def change do
    alter table(:times) do
      add :seconds, :integer
    end
  end
end
