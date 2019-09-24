defmodule Plausible.Goal.Cache do
  use GenServer
  use Plausible.Repo

  @moduledoc """
  The purpose of this module is to provide an in-memory cache
  for goals. Goal completions (conversions) are captured eagerly,
  meaning we need fast access to the goals as pageviews and custom
  events are coming in.
  """

  def start_link() do
    GenServer.start_link(__MODULE__, [])
  end

  def init(opts) do
    :ets.new(:goal_cache, [:set, :public, :named_table])

    for goal <- Repo.all(Plausible.Goal) do
      goal_created(goal)
    end

    {:ok, opts}
  end

  def find_goal(:pageview, domain, pathname) do
    case :ets.lookup(:goal_cache, {:pageview, domain, pathname}) do
      [] ->
        nil
      [{_key, val}] ->
        val
    end
  end

  def goal_created(goal) do
    key = {:pageview, goal.domain, goal.page_url}
    :ets.insert(:goal_cache, {key, goal.name})
  end
end
