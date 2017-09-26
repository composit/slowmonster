defmodule Slowmonster.AccountsTest do
  use Slowmonster.DataCase

  alias Slowmonster.Accounts

  describe "sessions" do
    alias Slowmonster.Accounts.Session

    @invalid_attrs %{}

    setup do
      user = user_fixture(%{username: "foo@bar.com", password: "s3cr3t"})

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

    @valid_attrs %{username: "usey", password_hash: "some password_hash"}
    @update_attrs %{username: "updatey", password_hash: "some updated password_hash"}
    @invalid_attrs %{username: nil, password_hash: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "get_user_by_username/1 returns the user with the given username" do
      user = user_fixture()
      assert Accounts.get_user_by_username(user.username) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.username == "usey"
      assert user.password_hash == "some password_hash"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "create_user/1 with username too short returns error changeset" do
      attrs = Map.put(@valid_attrs, :username, "")
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(attrs)
    end

    test "create_user/1 with password too short returns error changeset" do
      attrs = Map.put(@valid_attrs, :password, "12345")
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, user} = Accounts.update_user(user, @update_attrs)
      assert %User{} = user
      assert user.username == "updatey"
      assert user.password_hash == "some updated password_hash"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end
end
