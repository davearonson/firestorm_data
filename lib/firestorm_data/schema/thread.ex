defmodule FirestormData.Thread do
  use Ecto.Schema
  import Ecto.Changeset

  schema "threads" do
    field :title, :string
    # We use belongs_to to specify that this thread has a parent category
    belongs_to :category, FirestormData.Category

    timestamps()
  end

  def changeset(thread, params \\ %{}) do
    thread |> cast(params, [:category_id, :title])
  end
end
