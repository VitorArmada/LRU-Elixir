defmodule LruCacheValidere.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      LruCacheValidere.Repo,
      # Start the Telemetry supervisor
      LruCacheValidereWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: LruCacheValidere.PubSub},
      # Start the Endpoint (http/https)
      LruCacheValidereWeb.Endpoint,
      # Start a worker by calling: LruCacheValidere.Worker.start_link(arg)
      # {LruCacheValidere.Worker, arg}
      {LruCache, {Application.fetch_env!(:cache, :lru_cache_name),
                  Application.fetch_env!(:cache, :max_size)}}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LruCacheValidere.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    LruCacheValidereWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
