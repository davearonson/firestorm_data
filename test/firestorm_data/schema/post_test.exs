defmodule FirestormData.PostTest do
  import Ecto.Query
  alias FirestormData.{Category, User, Thread, Post, Repo}
  use ExUnit.Case

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    {:ok, category} = %Category{title: "Elixir"} |> Repo.insert
    {:ok, otp} = %Thread{title: "OTP is neat", category_id: category.id}
                 |> Repo.insert
    {:ok, josh} = %User{username: "josh",
                        email: "josh@dailydrip.com",
                        name: "Josh Adams"} |> Repo.insert
    {:ok, category: category, otp: otp, josh: josh}
  end

  test "creating a post", %{otp: otp, josh: josh} do
    post_changeset =
      %Post{}
      |> Post.changeset(%{thread_id: otp.id,
                          body: "I know, right?",
                          user_id: josh.id})

    assert {:ok, _} = Repo.insert post_changeset
  end

  describe "given some posts" do
    setup [:create_other_users, :create_sample_posts]

    test "finding a post by a user",
         %{post1: post1, post3: post3, josh: josh} do
      query = from p in Post,
                where: p.user_id == ^josh.id,
                preload: [:user]

      posts = Repo.all query
      assert Enum.map(posts, &(&1.id)) |> Enum.sort == [post1.id, post3.id]
      assert hd(posts).user.username == "josh"
    end

    test "counting the posts in a thread", %{otp: otp} do
      query = from p in Post, where: p.thread_id == ^otp.id

      assert Repo.aggregate(query, :count, :id) == 4
    end

    test "find those mentioning a string",
         %{post1: post1, post2: post2} do
      query = from p in Post, where: like(p.body, "%by%")
      ids = Repo.all(query) |> Enum.map(&(&1.id)) |> Enum.sort
      assert ids == [post1.id, post2.id]
    end

  end


  defp create_other_users(_) do
    adam =
      %User{username: "adam", email: "adam@dailydrip.com", name: "Adam Dill"}
      |> Repo.insert!

    {:ok, adam: adam}
  end

  defp create_sample_posts(%{otp: otp, josh: josh, adam: adam}) do
    post1 =
      %Post{}
      |> Post.changeset(%{thread_id: otp.id,
                          user_id: josh.id,
                          body: "post by josh"})
      |> Repo.insert!

    post2 =
      %Post{}
      |> Post.changeset(%{thread_id: otp.id,
                          user_id: adam.id,
                          body: "post by adam"})
      |> Repo.insert!

    post3 =
      %Post{}
      |> Post.changeset(%{thread_id: otp.id,
                          user_id: josh.id,
                          body: "post from josh"})
      |> Repo.insert!

    post4 =
      %Post{}
      |> Post.changeset(%{thread_id: otp.id,
                          user_id: adam.id,
                          body: "post from adam"})
      |> Repo.insert!

    {:ok, post1: post1, post2: post2, post3: post3, post4: post4}
  end

end
