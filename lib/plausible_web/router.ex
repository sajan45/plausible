defmodule PlausibleWeb.Router do
  use PlausibleWeb, :router
  use Plug.ErrorHandler
  use Sentry.Plug
  @two_weeks_in_seconds 60 * 60 * 24 * 14

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :assign_device_id
    plug PlausibleWeb.SessionTimeoutPlug, timeout_after_seconds: @two_weeks_in_seconds
    plug PlausibleWeb.AuthPlug
    plug PlausibleWeb.LastSeenPlug
  end

  pipeline :api do
    plug :accepts, ["application/json"]
    plug :fetch_session
    plug PlausibleWeb.AuthPlug
  end

  if Mix.env == :dev do
    forward "/sent-emails", Bamboo.SentEmailViewerPlug
  end

  scope "/api", PlausibleWeb do
    pipe_through :api

    post "/page", Api.ExternalController, :page
    get "/error", Api.ExternalController, :error

    post "/paddle/webhook", Api.PaddleController, :webhook

    get "/:domain/status", Api.InternalController, :domain_status
    get "/:domain/referrers", StatsController, :referrers
    get "/:domain/referrers/:referrer", StatsController, :referrer_drilldown
    get "/:domain/pages", StatsController, :pages
    get "/:domain/countries", StatsController, :countries
    get "/:domain/operating-systems", StatsController, :operating_systems
    get "/:domain/browsers", StatsController, :browsers
    get "/:domain/compare", StatsController, :compare
    get "/:domain/current-visitors", StatsController, :current_visitors
  end

  scope "/", PlausibleWeb do
    pipe_through :browser

    get "/register", AuthController, :register_form
    post "/register", AuthController, :register
    get "/claim-activation", AuthController, :claim_activation_link
    get "/login", AuthController, :login_form
    post "/login", AuthController, :login
    get "/claim-login", AuthController, :claim_login_link
    get "/password/request-reset", AuthController, :password_reset_request_form
    post "/password/request-reset", AuthController, :password_reset_request
    get "/password/reset", AuthController, :password_reset_form
    post "/password/reset", AuthController, :password_reset
    get "/password", AuthController, :password_form
    post "/password", AuthController, :set_password
    post "/logout", AuthController, :logout
    get "/settings", AuthController, :user_settings
    put "/settings", AuthController, :save_settings
    delete "/me", AuthController, :delete_me

    get "/auth/google/callback", AuthController, :google_auth_callback

    get "/", PageController, :index
    get "/privacy", PageController, :privacy
    get "/terms", PageController, :terms
    get "/data-policy", PageController, :data_policy
    get "/feedback", PageController, :feedback
    get "/roadmap", PageController, :roadmap
    get "/contact", PageController, :contact_form
    post "/contact", PageController, :submit_contact_form

    get "/billing/change-plan", BillingController, :change_plan_form
    post "/billing/change-plan/:plan_name", BillingController, :change_plan
    get "/billing/upgrade", BillingController, :upgrade
    get "/billing/success", BillingController, :success

    get "/sites/new", SiteController, :new
    post "/sites", SiteController, :create_site
    post "/sites/:website/make-public", SiteController, :make_public
    post "/sites/:website/make-private", SiteController, :make_private
    post "/sites/:website/weekly-report/enable", SiteController, :enable_weekly_report
    post "/sites/:website/weekly-report/disable", SiteController, :disable_weekly_report
    put "/sites/:website/weekly-report", SiteController, :update_weekly_settings
    post "/sites/:website/monthly-report/enable", SiteController, :enable_monthly_report
    post "/sites/:website/monthly-report/disable", SiteController, :disable_monthly_report
    put "/sites/:website/monthly-report", SiteController, :update_monthly_settings
    get "/:website/snippet", SiteController, :add_snippet
    get "/:website/settings", SiteController, :settings
    put "/:website/settings", SiteController, :update_settings
    delete "/:website", SiteController, :delete_site

    get "/stats/:domain/referrers", StatsController, :referrers_preview
    get "/stats/:domain/pages", StatsController, :pages_preview
    get "/stats/:domain/countries", StatsController, :countries_preview
    get "/stats/:domain/screen-sizes", StatsController, :screen_sizes_preview
    get "/stats/:domain/operating-systems", StatsController, :operating_systems_preview
    get "/stats/:domain/browsers", StatsController, :browsers_preview
    get "/stats/:domain/conversions", StatsController, :conversions_preview
    get "/stats/:domain/main-graph", StatsController, :main_graph
    get "/:website/*path", StatsController, :stats
  end

  def assign_device_id(conn, _opts) do
    if is_nil(Plug.Conn.get_session(conn, :device_id)) do
      Plug.Conn.put_session(conn, :device_id, UUID.uuid4())
    else
      conn
    end
  end
end
