defmodule Plausible.Repo.Migrations.AddGoals do
  use Ecto.Migration

  def change do
    create table(:goals, primary_key: false) do
      add :domain, :text, null: false, primary_key: true
      add :name, :text, null: false, primary_key: true
      add :event_name, :text
      add :page_url, :text

      timestamps()
    end

    create unique_index(:goals, [:domain, :name])

    create table(:conversions) do
      add :domain, :text, null: false
      add :goal_name, :text, null: false
      add :user_id, :uuid, null: false
      add :referrer_source, :text
      add :entry_page, :text
      add :time, :naive_datetime, null: false
    end
  end
end
