defmodule CoPlanHub.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      CoPlanHubWeb.Telemetry,
      CoPlanHub.Repo,
      {DNSCluster, query: Application.get_env(:co_plan_hub, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: CoPlanHub.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Swoosh.Finch},
      # Start a worker by calling: CoPlanHub.Worker.start_link(arg)
      # {CoPlanHub.Worker, arg},
      # Start to serve requests, typically the last entry
      CoPlanHubWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CoPlanHub.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CoPlanHubWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
