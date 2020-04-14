defmodule PlausibleWeb.StatsControllerTest do
  use PlausibleWeb.ConnCase
  use Plausible.Repo
  import Plausible.TestUtils

  describe "GET /:website - anonymous user" do
    test "public site - shows site stats", %{conn: conn} do
      insert(:site, domain: "public-site.io", public: true)
      insert(:pageview, domain: "public-site.io")

      conn = get(conn, "/public-site.io")
      assert html_response(conn, 200) =~ "stats-react-container"
    end

    test "can not view stats of a private website", %{conn: conn} do
      insert(:pageview, domain: "some-other-site.com")

      conn = get(conn, "/some-other-site.com")
      assert html_response(conn, 404) =~ "There&#39;s nothing here"
    end
  end

  describe "GET /:website - as a logged in user" do
    setup [:create_user, :log_in, :create_site]

    test "can view stats of a website I've created", %{conn: conn, site: site} do
      insert(:pageview, domain: site.domain)

      conn = get(conn, "/" <> site.domain)
      assert html_response(conn, 200) =~ "stats-react-container"
    end

    test "can not view stats of someone else's website", %{conn: conn} do
      insert(:pageview, domain: "some-other-site.com")

      conn = get(conn, "/some-other-site.com")
      assert html_response(conn, 404) =~ "There&#39;s nothing here"
    end
  end

  describe "GET /:website/visitors.csv" do
    setup [:create_user, :log_in, :create_site]

    test "exports graph as csv", %{conn: conn, site: site} do
      insert(:pageview, domain: site.domain)
      today = Timex.today() |> Timex.format!("{ISOdate}")

      conn = get(conn, "/" <> site.domain <> "/visitors.csv")
      assert response(conn, 200) =~ "Date,Visitors"
      assert response(conn, 200) =~ "#{today},1"
    end
  end

  describe "GET /share/:slug" do
    test "prompts a password for a password-protected link", %{conn: conn} do
      site = insert(:site)
      link = insert(:shared_link, site: site, password_hash: Plausible.Auth.Password.hash("password"))

      conn = get(conn, "/share/#{link.slug}")
      assert response(conn, 200) =~ "Enter password"
    end

    test "logs anonymous user in straight away if the link is not password-protected", %{conn: conn} do
      site = insert(:site)
      link = insert(:shared_link, site: site)
      insert(:pageview, domain: site.domain)

      conn = get(conn, "/share/#{link.slug}")
      assert redirected_to(conn, 302) == "/#{site.domain}"

      conn = get(conn, "/#{site.domain}")
      assert html_response(conn, 200) =~ "stats-react-container"
    end
  end

  describe "POST /share/:slug/authenticate" do
    test "logs anonymous user in with correct password", %{conn: conn} do
      site = insert(:site)
      link = insert(:shared_link, site: site, password_hash: Plausible.Auth.Password.hash("password"))
      insert(:pageview, domain: site.domain)

      conn = post(conn, "/share/#{link.slug}/authenticate", %{password: "password"})
      assert redirected_to(conn, 302) == "/#{site.domain}"

      conn = get(conn, "/#{site.domain}")
      assert html_response(conn, 200) =~ "stats-react-container"
    end

    test "shows form again with wrong password", %{conn: conn} do
      site = insert(:site)
      link = insert(:shared_link, site: site, password_hash: Plausible.Auth.Password.hash("password"))

      conn = post(conn, "/share/#{link.slug}/authenticate", %{password: "WRONG!"})
      assert html_response(conn, 200) =~ "Enter password"
    end
  end
end
