defmodule LruCacheValidereWeb.LRUController do
    use LruCacheValidereWeb, :controller

    def index(conn, _params) do
      json conn,
      %{:message => "Least Recently Used Cache API: OK"}
    end

    def get(conn, params) do
      case params do
        %{"key" => key} ->
          {status_code, value} = LruCache.get(key)
          respond(conn, status_code, %{:value => value})
        _error->
          respond(conn, :bad_request,
          %{:error => "Invalid parameters provided."})
      end
    end

    def get_status(conn, _params) do
      case LruCache.get_status() do
        {:ok, status} ->
          respond(conn, :ok, %{:status => status})
        _error ->
          respond(conn, :bad_request,
          %{:error => "Failed to fetch status of LRU Cache."})
      end

    end

    def put(conn, params) do
      case params do
        %{"key" => key, "value" => value} ->
          case LruCache.put(key, value) do
            :ok ->
              respond(conn, :ok, %{:message => :ok})
            _error ->
              respond(conn, :bad_request,
               %{:error => "Failed to put values in the LRU Cache."})
          end
        _error->
          respond(conn, :bad_request,
          %{:error => "Invalid parameters provided."})
      end
    end

    def delete(conn, _) do
      case LruCache.delete() do
        :ok ->
          respond(conn, :ok,
          %{:message => :ok})
        _error ->
          respond(conn, :bad_request,
          %{:error => "Failed to delete the LRU Cache."})
      end
    end

    def size(conn, params) do
      case params do
        %{"size" => value} ->
        case LruCache.size(value) do
          :ok ->
            respond(conn, :ok,
            %{:message => :ok})
          _error ->
            respond(conn, :bad_request,
            %{:error => "Failed to resize the LRU Cache."})
          end
      end
    end

    defp respond(conn, status_code, res_message) do
      conn
      |> put_status(status_code)
      |> json(res_message)
    end
  end
