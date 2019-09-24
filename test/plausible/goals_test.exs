defmodule Plausible.GoalsTest do
  use Plausible.DataCase, async: false
  alias Plausible.Goals

  describe "create" do
    test "creates a goal in repo" do
      site = build(:site)
      Goals.create(site, %{"page_path" => "/success"})

      goal = Repo.one(Plausible.Goal)

      assert goal.domain == site.domain
      assert goal.page_path == "/success"
      assert goal.name == "Visit /success"
    end

    test "creates goal in memory cache as well" do
      site = build(:site)
      Goals.create(site, %{"page_path" => "/success"})

      found = Plausible.Goal.Cache.find_goal(:pageview, site.domain, "/success")

      assert found == "Visit /success"
    end
  end
end
