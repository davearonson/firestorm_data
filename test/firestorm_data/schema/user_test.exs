defmodule FirestormData.UserTest do
  alias FirestormData.{User, Repo}
  use ExUnit.Case

  # We set our test adapter to use the sandbox. This allows us to checkout
  # connections in our tests from a sandbox, so concurrent tests won't step on
  # one another and so they're automatically cleaned up after each test.
  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  test "creating a user" do
    josh_changeset = %User{}
                     |> User.changeset(%{name: "Josh Adams",
                                         email: "josh@dailydrip.com"})
    assert {:ok, _} = Repo.insert josh_changeset
  end

  test "creating a user without an email" do
    josh_changeset = %User{} |> User.changeset(%{name: "Josh Adams"})
    assert({:email, {"can't be blank", [validation: :required]}} in
           josh_changeset.errors)
  end

  test "creating a user with an invalid email" do
    josh_changeset = %User{}
                     |> User.changeset(%{name: "Josh Adams",
                                         email: "notanemail"})
    refute josh_changeset.valid?
  end

  test "creating two users with the same email address" do
    email = "josh@dailydrip.com"
    jc1 = %User{} |> User.changeset(%{name: "Josh Adams", email: email})
    jc2 = %User{} |> User.changeset(%{name: "Just Joshing", email: email})
    assert {:ok, _} = Repo.insert(jc1)
    {:error, new_changeset} = Repo.insert(jc2)
    assert {:email, {"has already been taken", []}} in new_changeset.errors
  end
  
end
