defmodule PhoenixTrello.CurrentUserController do
  use PhoenixTrello.Web, :controller
  require Logger
  alias PhoenixTrello.{Repo,User}

  def show(conn, _) do
    user = Map.get(conn.assigns, :current_user)
    Logger.debug("This is user email: #{user.email}")
    conn
    |> put_status(:ok)
    |> render("show.json", user: user)
  end
end
