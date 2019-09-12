defmodule Plausible.Goal.Conversion do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "conversions" do
    field :domain, :string, primary_key: true
    field :goal_name, :string, primary_key: true
    field :referrer_source, :string
    field :entry_page, :string
    field :time, :naive_datetime, null: false
  end

  def changeset(site, attrs \\ %{}) do
    site
    |> cast(attrs, [:domain, :goal_name, :referrer_source, :entry_page, :time])
    |> validate_required([:domain, :goal_name])
  end
end
