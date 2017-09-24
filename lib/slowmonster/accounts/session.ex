defmodule Slowmonster.Accounts.Session do
  use Ecto.Schema
  import Ecto.Changeset
  alias Slowmonster.Accounts.Session


  schema "sessions" do
    field :token, :string
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(%Session{} = session, attrs) do
    session
    |> cast(attrs, [:user_id])
    |> validate_required([:user_id])
  end

  def registration_changeset(%Session{} = session, attrs) do
    session
    |> changeset(attrs)
    |> put_change(:token, SecureRandom.urlsafe_base64())
  end
end
