# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :phoenix_trello,
  ecto_repos: [PhoenixTrello.Repo]

config :phoenix_trello, :auth0,
  app_baseurl: "localhost",
  app_id: "abs29a01a=01a9as",
  app_secret: "Z3Jh2uh75Nt+7y60vMAArXzHrC7WbHISIGE4B7wg2I6PscDzeFPLDptam9ld/pbr"

# Configures the endpoint
config :phoenix_trello, PhoenixTrello.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Z3Jh2uh75Nt+7y60vMAArXzHrC7WbHISIGE4B7wg2I6PscDzeFPLDptam9ld/pbr",
  render_errors: [view: PhoenixTrello.ErrorView, accepts: ~w(html json)],
  pubsub: [name: PhoenixTrello.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
