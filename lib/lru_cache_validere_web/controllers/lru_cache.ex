defmodule LruCache do
    use GenServer
  
    defstruct [:table_name, 
    :max_size, 
    :size, 
    :status]
  
    def start_link({name, max_size}) do
      GenServer.start_link(__MODULE__, {name, max_size}, name: Cache)
    end

    def get(key) do
      GenServer.call(Cache, {:get, key})
    end
  
    def get_status() do
      GenServer.call(Cache, :get_status)
    end
  
    def put(key, value) do
      GenServer.cast(Cache, {:put, key, value})
    end
  
    def delete() do
      GenServer.cast(Cache, :delete)
    end

    @impl true
    def init({name, max_size}) do
      :ets.new(name, [:set, :public, :named_table])
      {:ok, %LruCache{table_name: name, max_size: max_size, size: 0, status: []}}
    end
  
    @impl true
    def handle_call({:get, key}, _from, state) do
      case :ets.match(state.table_name, {key, :"$1"}) do
        [] ->
          {:reply, {:not_found, :not_found}, state}
        [[value]] ->
          new_status = update_lru_status(key, state.status)
          {:reply, {:ok, value}, %{state | :status => new_status}}
      end
    end
  
    @impl true
    def handle_call(:get_status, _from, state) do
      {:reply, {:ok, state.status}, state}
    end
  
    @impl true
    def handle_cast({:put, key, value}, state) do
      case :ets.match(state.table_name, {key, :"$1"}) do
        [_] ->
          new_status = update_lru_status(key, state.status)
          :ets.insert(state.table_name, {key, value})
          {:noreply, %{state | :status => new_status}}
        [] ->
          new_status = state.status ++ [key]
          :ets.insert(state.table_name, {key, value})
          if state.size < state.max_size do
            {:noreply, %{state | :status => new_status, :size => state.size + 1}}
          else
            [evict_key | rest_status] = new_status
            :ets.delete(state.table_name, evict_key)
            {:noreply, %{state | :status => rest_status}}
          end
      end
    end

    @impl true
    def handle_cast(:delete, state) do
      :ets.delete_all_objects(state.table_name)
      {:noreply, %{state | :status => [], :size => 0}}
    end
    
    defp update_lru_status(key, [head | tail], prev \\ []) do
      if key == head do
        prev ++ tail ++ [head]
      else
        update_lru_status(key, tail, prev ++ [head])
      end
    end
  end
  