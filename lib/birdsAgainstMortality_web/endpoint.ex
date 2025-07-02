defmodule BirdsAgainstMortalityWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :birdsAgainstMortality

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_birdsAgainstMortality_key",
    signing_salt: "DM/wSPcA"
  ]

  socket "/socket", BirdsAgainstMortalityWeb.UserSocket,
    websocket: true,
    longpoll: false

  # Updated LiveView socket with more explicit WebSocket config
  socket "/live", Phoenix.LiveView.Socket,
    websocket: [
      connect_info: [session: @session_options],
      check_origin: true,  # Temporarily disable for testing
      timeout: 45_000,
      transport_log: :debug  # Add logging to see what's happening
    ]

  # Serve at "/" the static files from "priv/static" directory.
  plug Plug.Static,
    at: "/",
    from: :birdsAgainstMortality,
    gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt vendor)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :birdsAgainstMortality
  end

  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug BirdsAgainstMortalityWeb.Router
end
