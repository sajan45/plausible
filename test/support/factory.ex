defmodule Plausible.Factory do
  use ExMachina.Ecto, repo: Plausible.Repo

  def user_factory(attrs) do
    pw = Map.get(attrs, :password, "password")

    user = %Plausible.Auth.User{
      name: "Jane Smith",
      email: sequence(:email, &"email-#{&1}@example.com"),
      password_hash: Plausible.Auth.Password.hash(pw)
    }

    merge_attributes(user, attrs)
  end

  def site_factory do
    domain = sequence(:domain, &"example-#{&1}.com")

    %Plausible.Site{
      domain: domain,
      timezone: "UTC",
    }
  end

  def pageview_factory do
    hostname = sequence(:domain, &"example-#{&1}.com")

    %Plausible.Pageview{
      hostname: hostname,
      pathname: "/",
      new_visitor: true,
      user_id: UUID.uuid4(),
    }
  end

  def subscription_factory do
    %Plausible.Billing.Subscription{
      paddle_subscription_id: sequence(:paddle_subscription_id, &"subscription-#{&1}"),
      paddle_plan_id: sequence(:paddle_plan_id, &"plan-#{&1}"),
      cancel_url: "cancel.com",
      update_url: "cancel.com",
      status: "active",
      next_bill_amount: "6.00",
      next_bill_date: Timex.today()
    }
  end

  def google_auth_factory do
    %Plausible.Site.GoogleAuth{
      email: sequence(:google_auth_email, &"email-#{&1}@email.com"),
      refresh_token: "123",
      access_token: "123",
      expires: Timex.now() |> Timex.shift(days: 1)
    }
  end

  def goal_factory do
    domain = sequence(:goal_domain, &"example-#{&1}.com")
    name = sequence(:goal_name, &"goal-#{&1}")

    %Plausible.Goal{
      domain: domain,
      name: name,
      page_path: "/page"
    }
  end
end
