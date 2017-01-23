defmodule PhoenixTrello.User do

  use PhoenixTrello.Web, :model

  alias PhoenixTrello.{Board, UserBoard}

  @derive { Poison.Encoder, only: [:id, :first_name, :last_name, :email] }

  schema "users" do
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :encrypted_password, :string
    field :password, :string, virtual: true

    has_many :owned_boards, Board
    has_many :user_boards, UserBoard
    has_many :boards, through: [:user_boards, :board]

    timestamps()
  end


  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:first_name, :last_name, :email, :password, :encrypted_password])
    |> validate_required([:first_name, :last_name, :email])
    |> unique_constraint(:email)
    |> validate_length(:first_name, min: 2)
    |> validate_length(:last_name, min: 2)
    |> validate_format(:email, ~r/@/)
    |> validate_length(:password, min: 5)
    |> validate_confirmation(:password, message: "Password does not match")
    |> unique_constraint(:email, message: "Email already taken")
    |> generate_encrypted_password
  end

  def generate_token(%PhoenixTrello.User{} = user) do
    alias Joken, as: J
    %J.Token{claims: %{id: user.id, email: user.email}}
    |> J.with_json_module(Poison)
    |> J.with_signer(J.hs256(Application.get_env(:phoenix_trello, :auth0)[:app_secret]))
    |> J.with_aud(Application.get_env(:phoenix_trello, :auth0)[:app_id])
    |> J.with_iat
    |> J.with_iss(Application.get_env(:phoenix_trello, :auth0)[:app_baseurl])
    |> J.with_exp(J.current_time + 86_400)
    |> J.sign
    |> J.get_compact
  end


  defp generate_encrypted_password(current_changeset) do
    case current_changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(current_changeset, :encrypted_password, Comeonin.Bcrypt.hashpwsalt(password))
      _ ->
        current_changeset
    end
  end
end
