defmodule Plausible.Goals do
  use Plausible.Repo
  alias Plausible.Goal

  def create(site, params) do
    params = Map.merge(params, %{
      "name" => name_for(params),
      "domain" => site.domain
    })

    changeset = Goal.changeset(%Goal{}, params)

    Ecto.Multi.new
    |> Ecto.Multi.insert(:goal, changeset)
    |> Ecto.Multi.run(:cache, &add_goal_to_cache/2)
    |> Repo.transaction
  end

  def for_site(domain) do
    Repo.all(
      from g in Goal,
      where: g.domain == ^domain
    )
  end

  def delete(site, goal_name) do
    Repo.one(
      from g in Goal,
      where: g.domain == ^site.domain and g.name == ^goal_name
    ) |> Repo.delete!
  end

  defp name_for(%{"event_name" => name}) when name != "" do
    name
  end

  defp name_for(%{"page_path" => path}) when path != "" do
    "Visit #{path}"
  end

  defp name_for(_), do: nil

  defp add_goal_to_cache(_, %{goal: goal}) do
    Goal.Cache.goal_created(goal)
    {:ok, goal}
  end
end
