defmodule LruCacheValidere.Repo do
  use Ecto.Repo,
    otp_app: :lru_cache_validere,
    adapter: Ecto.Adapters.Postgres
end
