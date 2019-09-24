defmodule Plausible.Goal.CacheTest do
  use Plausible.DataCase, async: false
  alias Plausible.Goal.Cache

  setup do
    :ets.delete_all_objects(:goal_cache)
    :ok
  end

  describe "caching goals" do
    test "returns nil for non-existent goal" do
      assert Cache.find_goal(:pageview, "example.com", "/success") == nil
    end

    test "caches the goal" do
      goal = build(:goal,
        domain: "example.com",
        name: "Visit /success",
        page_path: "/success"
      )

      Cache.goal_created(goal)

      assert Cache.find_goal(:pageview, "example.com", "/success") == "Visit /success"
    end
  end
end
