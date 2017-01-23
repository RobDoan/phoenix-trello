defmodule PhoenixTrello.RegistrationController do
  require Logger
  use PhoenixTrello.Web, :controller

  alias PhoenixTrello.{Repo, User}

  plug :scrub_params, "user" when action in [:create]


  def create(conn, %{"user" => user_params}) do
    changeset = User.changeset(%User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, user} ->
        token = User.generate_token(user)
        conn
        |> put_status(201)
        |> render(PhoenixTrello.SessionView, "show.json", jwt: token, user: user)
      {:error, changeset}   ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(PhoenixTrello.RegistrationView, "error.json", changeset: changeset)
    end
  end
end
