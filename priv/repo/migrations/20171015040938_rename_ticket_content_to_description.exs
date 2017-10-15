defmodule Slowmonster.Repo.Migrations.RenameTicketContentToDescription do
  use Ecto.Migration

  def change do
    rename table(:tickets), :content, to: :description
  end
end
