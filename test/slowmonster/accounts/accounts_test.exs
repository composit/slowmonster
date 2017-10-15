defmodule Slowmonster.AccountsTest do
  use Slowmonster.DataCase

  import Slowmonster.Factory

  alias Slowmonster.Accounts

  describe "sessions" do
    alias Slowmonster.Accounts.Session

    @invalid_attrs %{}

    setup do
      user = insert(:user, %{username: "foo@bar.com", password: "s3cr3t"})

      {:ok, valid_attrs: %{user_id: user.id}}
    end

    test "create_session/1 with valid data creates a session", %{valid_attrs: valid_attrs} do
      assert {:ok, %Session{} = session} = Accounts.create_session(valid_attrs)
      assert session.token != nil
    end

    test "create_session/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_session(@invalid_attrs)
    end
  end

  describe "users" do
    alias Slowmonster.Accounts.User

    test "list_users/0 returns all users" do
      user = insert(:user)
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = insert(:user)
      assert Accounts.get_user!(user.id) == user
    end

    test "get_user_by_username/1 returns the user with the given username" do
      user = insert(:user)
      assert Accounts.get_user_by_username(user.username) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = _} = Accounts.create_user(params_for(:user))
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(%{})
    end

    test "create_user/1 with username too short returns error changeset" do
      attrs = Map.put(params_for(:user), :username, "")
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(attrs)
    end

    test "create_user/1 with password too short returns error changeset" do
      attrs = Map.put(params_for(:user), :password, "12345")
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = insert(:user)
      assert {:ok, user} = Accounts.update_user(user, %{username: "updatey"})
      assert %User{} = user
      assert user.username == "updatey"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = insert(:user)
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, %{username: ""})
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = insert(:user)
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = insert(:user)
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end
end
