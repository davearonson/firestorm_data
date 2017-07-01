defmodule FirestormData.ThreadTest do
  import Ecto.Query
  alias FirestormData.{Category, Thread, Repo, User, Post}
  use ExUnit.Case

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    {:ok, category} = %Category{title: "Elixir"} |> Repo.insert
    {:ok, category: category}
  end

  test "creating a thread", %{category: category} do
    otp_changeset =
      %Thread{}
      |> Thread.changeset(%{category_id: category.id, title: "OTP is neat"})

    assert {:ok, _} = Repo.insert otp_changeset
  end

  test "count posts", %{category: category} do
    count = 3
    {:ok, josh} = %User{username: "josh",
                        email: "josh@dailydrip.com",
                        name: "Josh Adams"} |> Repo.insert
    {:ok, otp_thread}         = %Thread{category_id: category.id,
                                 title: "OTP is neat"} |> Repo.insert
    {:ok, other_thread}       = %Thread{category_id: category.id,
                                 title: "Elixir is neat"} |> Repo.insert
    {:ok, yet_another_thread} = %Thread{category_id: category.id,
                                 title: "Phoenix is neat"} |> Repo.insert
    1..count   |> Enum.map(&(create_post(&1, josh.id, otp_thread.id)))
    1..count+1 |> Enum.map(&(create_post(&1, josh.id, other_thread.id)))
    1..count-1 |> Enum.map(&(create_post(&1, josh.id, yet_another_thread.id)))
    query = from p in Post,
            select: count(p.id),
            where: p.thread_id == ^otp_thread.id
    assert Repo.one(query) == count
  end


  defp create_post(num, user_id, thread_id) do
    {:ok, _} = %Post{thread_id: thread_id,
                     user_id: user_id,
                     body: "post # #{num} in this thread"} |> Repo.insert
  end

end
