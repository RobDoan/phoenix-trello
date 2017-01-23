defmodule PhoenixTrello.JWTHelper do
  import Joken, except: [verify: 1]
  @doc """
   user for future verification, eg. on socket connect
  """
  def verify(_jwt) do
    verify
  end

  @doc """
   user for verification via plug
   issuer should be our autho domain
   app_metadata must be present in id_token
  """

  def verify do
    %Joken.Token{}
    |> with_json_module(Poison)
    |> with_signer(hs256(config[:app_secret]))
    |> with_validation("aud", &(&1 == config[:app_id]))
    |> with_validation("exp", &(&1 > current_time))
    |> with_validation("iat", &(&1 <= current_time))
    |> with_validation("iss", &(&1 == config[:app_baseurl]))
  end

  @doc """
    create token from  client id and secret.
    Used for uniq test
  """
  def create_bearer_token(auth_scopes, config_items \\ %{signer: :app_secret, aud: :app_id}) do
    %Joken.Token{claims: auth_scopes}
    |> with_json_module(Poison)
    |> with_signer(hs256(config[config_items[:signer]]))
    |> with_aud(config[config_items[:aud]])
    |> with_iat
    |> with_iss(config[:app_baseurl])
    |> with_exp(current_time + 86_400)
    |> sign
    |> get_compact
  end

  @doc """
  Return error message for `on_error`
  """
  def error(conn, _msg) do
    {conn, %{:errors => %{:detail => "unauthorized"}}}
  end

  defp config, do: Application.get_env(:phoenix_trello, :auth0)
end
