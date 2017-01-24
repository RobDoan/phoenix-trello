defmodule PhoenixTrello.UserSocket do
  use Phoenix.Socket

  alias PhoenixTrello.{Repo, User}

  ## Channels
  # channel "room:*", PhoenixTrello.RoomChannel
  channel "users:*", PhoenixTrello.UserChannel
  channel "boards:*", PhoenixTrello.BoardChannel

  ## Transports
  transport :websocket, Phoenix.Transports.WebSocket
  transport :longpoll, Phoenix.Transports.LongPoll

  def connect(%{"token" => token}, socket) do
    case PhoenixTrello.JWTHelper.verify(token) do
      %Joken.Token{error: nil, claims: claims} ->
        socket
        |> load_current_user(claims)
      _ ->
        :error
    end
  end

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  def connect(_params, socket) do
    # {:ok, socket}
    :error
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  def id(socket), do: "users_socket:#{socket.assigns.current_user.id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     PhoenixTrello.Endpoint.broadcast("users_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(_socket), do: nil

  defp load_current_user(socket, claims) do
    case Repo.get_by(User, id: claims["id"]) do
      %User{} = user ->
        {:ok, assign(socket, :current_user, user)}
      _ ->
        :error
    end
  end
end
