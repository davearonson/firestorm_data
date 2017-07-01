defmodule FirestormData.CategoryTest do
  import Ecto.Query
  alias FirestormData.{Category, Repo, Thread, Post}
  use ExUnit.Case

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  test "creating a category" do
    elixir_changeset = %Category{} |> Category.changeset(%{title: "Elixir"})
    assert {:ok, _} = Repo.insert elixir_changeset
  end

  test "find its three threads with the most recent posts" do
    {:ok, cat} = %Category{title: "Elixir"} |> Repo.insert
    {:ok, cat2} = %Category{title: "Diet Coke"} |> Repo.insert
    threads = (1..5) |> Enum.map(&create_thread(&1, cat.id))
    threads |> Enum.map(&create_post/1)
    # reverse so the last 3 used are the first 3 created,
    # just to get at them more easily in the comparison :-)
    threads |> Enum.reverse |> Enum.map(&create_post/1)
    # make some more threads with recent posts, in another category
    (1..4) |> Enum.map(&create_thread(&1, cat2.id)) |> Enum.map(&create_post/1)

    expected = threads |> Enum.take(3) |> Enum.map(&(&1.id))
    assert most_recent_thread_ids(cat, 3) == expected
  end

  defp create_thread(tnum, cid) do
    {:ok, thread} = %Thread{title: "t#{tnum}", category_id: cid} |> Repo.insert
    thread
  end

  defp create_post(thread) do
    {:ok, _post} = %Post{thread_id: thread.id, body: "whatever"} |> Repo.insert
  end

  defp most_recent_thread_ids(cat, num) do
    query = from t in Thread,
            where: t.category_id == ^cat.id,
            group_by: t.id,
            join: p in assoc(t, :posts),
            order_by: [desc: max(p.updated_at)],
            limit: ^num
    Repo.all(query) |> Enum.map(&(&1.id))
  end

end
