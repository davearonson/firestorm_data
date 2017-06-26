defmodule FirestormData.User do
  import Ecto.Changeset
  use Ecto.Schema

  schema "users" do
    field :username, :string
    field :name, :string
    field :email, :string

    timestamps()
  end

  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [:username, :name, :email])
    |> validate_required([:email])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
  end

end
