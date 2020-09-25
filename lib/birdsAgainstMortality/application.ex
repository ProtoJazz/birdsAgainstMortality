  defmodule BirdsAgainstMortality.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      BirdsAgainstMortality.Repo,
      # Start the Telemetry supervisor
      BirdsAgainstMortalityWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: BirdsAgainstMortality.PubSub},
      # Start the Endpoint (http/https)
      BirdsAgainstMortalityWeb.Endpoint,
      {Registry, keys: :unique, name: BirdsAgainstMortality.GameRegistry},
      {DynamicSupervisor, strategy: :one_for_one, name: BirdsAgainstMortality.GameSupervisor}
      # Start a worker by calling: BirdsAgainstMortality.Worker.start_link(arg)
      # {BirdsAgainstMortality.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BirdsAgainstMortality.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    BirdsAgainstMortalityWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
