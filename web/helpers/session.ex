defmodule PhoenixTrello.Session do
  alias PhoenixTrello.{Repo, User}

  def authenticate(%{"email" => email, "password" => password}) do
    user = Repo.get_by(User, email: String.downcase(email))

    case check_password(user, password) do
      true -> {:ok, user}
      _ -> :error
    end
  end

  def current_user(conn) do
    case Map.get(conn.assigns, :current_user) do
      %PhoenixTrello.User{} = user ->
        user
      _ ->
        false
    end
  end

  defp check_password(user, password) do
    case user do
      nil -> Comeonin.Bcrypt.dummy_checkpw()
      _ -> Comeonin.Bcrypt.checkpw(password, user.encrypted_password)
    end
  end

end
