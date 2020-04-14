defmodule Plausible.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Plausible.Repo,
      PlausibleWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Plausible.Supervisor]
    {:ok, _} = Logger.add_backend(Sentry.LoggerBackend)
    Application.put_env(:plausible, :server_start, Timex.now())
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    PlausibleWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
