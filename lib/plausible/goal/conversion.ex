defmodule Plausible.Goal.Conversion do
  use Ecto.Schema
  import Ecto.Changeset

  schema "conversions" do
    field :domain, :string
    field :goal_name, :string
    field :user_id, :binary_id
    field :time, :naive_datetime, null: false
  end

  def changeset(site, attrs \\ %{}) do
    site
    |> cast(attrs, [:domain, :goal_name, :user_id, :time])
    |> validate_required([:domain, :goal_name, :user_id])
  end
end
