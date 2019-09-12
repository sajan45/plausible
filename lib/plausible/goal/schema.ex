defmodule Plausible.Goal do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "goals" do
    field :name, :string, primary_key: true
    field :domain, :string, primary_key: true
    field :event_name, :string
    field :page_url, :string

    timestamps()
  end

  def changeset(site, attrs \\ %{}) do
    site
    |> cast(attrs, [:domain, :name, :event_name, :page_url])
    |> validate_required([:domain, :name])
  end
end
