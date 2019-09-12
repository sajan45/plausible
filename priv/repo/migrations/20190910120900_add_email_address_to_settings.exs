defmodule Plausible.Repo.Migrations.AddEmailAddressToSettings do
  use Ecto.Migration
  use Plausible.Repo
  alias Plausible.Site.EmailSettings

  def change do
    alter table(:email_settings) do
      add :email, :citext, null: false
    end
  end
end
