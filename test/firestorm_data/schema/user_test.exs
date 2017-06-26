defmodule FirestormData.UserTest do
  import Ecto.Query
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

  describe "with posts" do
    alias FirestormData.{Category, Thread, Post}

    setup do
      {:ok, category} = %Category{title: "Elixir"} |> Repo.insert
      {:ok, t1} = %Thread{title: "OTP is neat", category_id: category.id}
                  |> Repo.insert
      {:ok, t2} = %Thread{title: "OTP is great", category_id: category.id}
                  |> Repo.insert
      {:ok, u1} = %User{username: "user1",
                        email: "u1@example.com",
                        name: "joe shmoe"} |> Repo.insert
      posts = 1..3 |> Enum.map(fn(i) ->
        query = %Post{thread_id: t1.id, body: "post #{i}", user_id: u1.id}
        {:ok, post} = query |> Repo.insert
        post
      end)
      more_posts = 1..3 |> Enum.map(fn(i) ->
        query = %Post{thread_id: t2.id, body: "post #{i}", user_id: u1.id}
        {:ok, post} = query |> Repo.insert
        post
      end)
      {:ok, category: category, threads: [t1, t2], u1: u1, posts: posts ++ more_posts}
    end

    test "find all a user's posts", %{posts: posts, u1: u1} do
      query = from p in Post, where: p.user_id == ^u1.id, select: [:id]
      post_ids_found = query |> Repo.all() |> Enum.map(&(&1.id))
      post_ids_expected = posts |> Enum.map(&(&1.id))
      assert post_ids_found == post_ids_expected
    end

    test "find all threads this user has posted to",
         %{threads: threads, u1: u1} do
      query = from p in Post,
              where: p.user_id == ^u1.id,
              select: [:thread_id],
              distinct: true
      thread_ids_found = query |> Repo.all() |> Enum.map(&(&1.thread_id))
      thread_ids_expected = threads |> Enum.map(&(&1.id))
      assert thread_ids_found == thread_ids_expected
    end

  end

end
