defmodule AuthToolkitWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use AuthToolkitWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using _options do
    quote do
      # The default endpoint for testing
      use AuthToolkitWeb, :verified_routes

      # Import conveniences for testing with connections
      import AuthToolkitWeb.ConnCase
      import Phoenix.ConnTest
      import Plug.Conn
      import Swoosh.TestAssertions

      @endpoint AuthToolkitWeb.Endpoint
    end
  end

  setup tags do
    AuthToolkit.DataCase.setup_sandbox(tags)
    {:ok, _} = start_supervised(AuthToolkitWeb.Endpoint)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  def log_in_user(conn, user) do
    token = AuthToolkit.generate_user_session_token(user)

    conn
    |> Phoenix.ConnTest.init_test_session(%{})
    |> Plug.Conn.put_session(:user_token, token)
  end

  @doc """
  Setup helper that registers and logs in users.

      setup :register_and_log_in_user

  It stores an updated connection and a registered user in the
  test context.
  """
  def register_and_log_in_user(%{conn: conn}) do
    user = AuthToolkitFixtures.user_fixture()
    %{conn: log_in_user(conn, user), user: user}
  end

  def html_escape(string) do
    {:safe, escaped} = Phoenix.HTML.html_escape(string)
    escaped
  end
end
