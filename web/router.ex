defmodule PhoenixTrello.Router do
  use PhoenixTrello.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug Joken.Plug,
            verify: &PhoenixTrello.JWTHelper.verify/0,
            on_error: &PhoenixTrello.JWTHelper.error/2
    plug :load_current_user
  end

  scope "/api", PhoenixTrello do
    pipe_through :api
    scope "/v1" do
      post "/registrations", RegistrationController, :create, private: %{joken_skip: true}

      get "/current_user", CurrentUserController, :show

      post "/sessions", SessionController, :create, private: %{joken_skip: true}
      delete "/sessions", SessionController, :delete

      resources "/boards", BoardController, only: [:index, :create] do
        resources "/cards", CardController, only: [:show]
      end

    end
  end

  scope "/", PhoenixTrello do
    pipe_through :browser # Use the default browser stack

    get "/*path", PageController, :index
  end


  defp load_current_user(conn, _) do
    if Map.get(conn.private, :joken_skip, false) do
      conn
    else
      claims = Map.get(conn.assigns, :joken_claims)
      conn
      |> evaluate_user(claims)
    end
  end

  defp evaluate_user(conn, claims) do
    case PhoenixTrello.Repo.get_by(PhoenixTrello.User, id: claims["id"]) do
        %PhoenixTrello.User{} = user ->
          Plug.Conn.assign(conn, :current_user, user)
        _ ->
          {conn, %{:errors => %{:detail => "User could not be found"}}}
    end
  end
  # Other scopes may use custom stacks.
  # scope "/api", PhoenixTrello do
  #   pipe_through :api
  # end
end
