# config/runtime.exs
import Config

database_url =
  System.get_env("DATABASE_URL") ||
    raise """
    environment variable DATABASE_URL is missing.
    For example: ecto://USER:PASS@HOST/DATABASE
    """

config :birdsAgainstMortality, BirdsAgainstMortality.Repo,
  # ssl: true,
  url: database_url,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

host = System.get_env("PHX_HOST") || "birds-against-morality.protojazz.ca"
port = String.to_integer(System.get_env("PORT") || "4000")

config :birdsAgainstMortality, BirdsAgainstMortalityWeb.Endpoint,
  server: true,
  url: [host: host, port: 443, scheme: "https"],
  http: [
    # Enable IPv6 and bind on all interfaces
    ip: {0, 0, 0, 0, 0, 0, 0, 0},
    port: port
  ],
  secret_key_base: secret_key_base,
  check_origin: false  # Temporarily disable for testing
