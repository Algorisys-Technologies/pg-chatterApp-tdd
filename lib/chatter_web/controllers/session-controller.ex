defmodule ChatterWeb.SessionController do
  use ChatterWeb, :controller

  def new(conn, _) do
    # IO.inspect("###########SessionController##########")
    # IO.inspect(conn.assigns)
    # IO.inspect("#####################")
    render(conn, "new.html")
  end

  def create(conn, %{"email" => email, "password" => password}) do
    case Doorman.authenticate(email, password) do
      nil ->
        conn
        |> put_flash(:error, "Invalid email or password")
        |> render("new.html")

      user ->
        conn
        |> Doorman.Login.Session.login(user)
        |> redirect(to: "/")
    end
  end

  def delete(conn, _params) do
    conn
    |> Doorman.Login.Session.logout()
    |> redirect(to: "/")

  end
end
