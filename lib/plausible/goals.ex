defmodule Plausible.Goals do
  use Plausible.Repo
  alias Plausible.Goal

  def create(site, params) do
    params = Map.merge(params, %{
      "name" => "Visit " <> params["page_path"],
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

  defp add_goal_to_cache(_, %{goal: goal}) do
    Goal.Cache.goal_created(goal)
    {:ok, goal}
  end
end
