defmodule SimpleRegistry do
  use GenServer
  
  def start_link() do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end
  
  def register(key) do
    Process.link(Process.whereis(__MODULE__))
    
    if :ets.insert_new(__MODULE__, {key, self()}) do
      :ok
    else
      :error
    end
  end
  
  def whereis(key) do
    case :ets.lookup(__MODULE__, key) do
      [{^key, pid}] -> pid
      [] -> nil
    end
  end
  
  # CALLBACK
  
  def init(_) do
    Process.flag(:trap_exit, true)
    :ets.new(__MODULE__, [:named_table, :public, read_concurrency: true, write_concurrency: true])
    {:ok, nil}
  end
  
  # def handle_call({:register, name, pid}, _from, registry) do
  #   case Map.get(registry, name) do
  #     nil -> # If there is no process with that name, name it thusly
  #       Process.link(pid)
  #       {:reply, :ok, Map.put(registry, name, pid)} 
  #     _ -> # Otherwise, return an error
  #       {:reply, :error, registry}
  #   end
  # end
  
  # def handle_call({:whereis, name}, _from, registry) do
  #   {:reply, Map.get(registry, name), registry}
  # end
  
  def handle_info({:EXIT, pid, _reason}, state) do
    :etc.match_delete(__MODULE__, {:_,  pid})
    {:noreply, state}
  end
  
  # defp deregister_pid(registry, pid) do
  #   registry
  #   |> Enum.reject(fn {_key, registered_process} -> registered_process == pid end)
  #   |> Enum.into(%{})
  # end
end
