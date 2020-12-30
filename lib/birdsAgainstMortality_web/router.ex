defmodule BirdsAgainstMortalityWeb.Router do
  use BirdsAgainstMortalityWeb, :router
  alias BirdsAgainstMortalityWeb.Plugs.User
  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {BirdsAgainstMortalityWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug User
  end

  pipeline :api do
    plug :accepts, ["json"]
  end
  scope "/api", BirdsAgainstMortalityWeb do
    pipe_through :api
    post "/cards", CardController, :new
  end

  scope "/", BirdsAgainstMortalityWeb do
    pipe_through :browser

    live "/decks", DeckLive.Index, :index
    live "/decks/new", DeckLive.Index, :new
    live "/decks/:id/edit", DeckLive.Index, :edit

    live "/decks/:id", DeckLive.Show, :show
    live "/decks/:id/show/edit", DeckLive.Show, :edit

    live "/page", PageLive, :index
    live "/game", GameLive, :index
    live "/", LandingPageLive, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", BirdsAgainstMortalityWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: BirdsAgainstMortalityWeb.Telemetry
    end
  end
end
