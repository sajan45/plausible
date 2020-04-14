defmodule Plausible.Event do
  use Ecto.Schema
  import Ecto.Changeset

  schema "events" do
    field :name, :string
    field :domain, :string
    field :hostname, :string
    field :pathname, :string
    field :fingerprint, :string

    field :referrer, :string
    field :referrer_source, :string
    field :initial_referrer, :string
    field :initial_referrer_source, :string
    field :country_code, :string
    field :screen_size, :string
    field :operating_system, :string
    field :browser, :string

    timestamps(inserted_at: :timestamp, updated_at: false)
  end

  def changeset(pageview, attrs) do
    pageview
    |> cast(attrs, [:name, :domain, :hostname, :pathname, :fingerprint, :operating_system, :browser, :referrer, :referrer_source, :initial_referrer, :initial_referrer_source, :country_code, :screen_size])
    |> validate_required([:name, :domain, :hostname, :pathname, :fingerprint])
  end
end
