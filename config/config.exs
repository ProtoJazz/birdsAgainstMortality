# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :birdsAgainstMortality,
  ecto_repos: [BirdsAgainstMortality.Repo]

# Configures the endpoint
config :birdsAgainstMortality, BirdsAgainstMortalityWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "DLbosYnbRwJYZYVW6NDSi0PxW/+dZoXPcFJsudTJtq2KHH2tBCZw6TQhbh56x8j+",
  render_errors: [view: BirdsAgainstMortalityWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: BirdsAgainstMortality.PubSub,
  live_view: [signing_salt: "6acL7hrP"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :birdsAgainstMortality, :basic_auth, username: System.get_env("ITEM_IMPORT_USERNAME"), password: System.get_env("ITEM_IMPORT_PASSWORD")

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
