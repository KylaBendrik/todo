defmodule SimpleRegistry do
  use GenServer
  
  def start_link() do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end
  
  def register(name) do
    GenServer.call(__MODULE__, {:register, key, self()})
  end
  
  def whereis(name) do
    GenServer.call(__MODULE__, {:whereis, key})
  end
  
  # CALLBACK
  
  def init(_) do
    Process.flag(:trap_exit, true)
    {:ok, %{}} # The registry's state should be a map <-
  end
  
  def handle_call({:register, name}, _from, registry) do
    case Map.get(registry, name) do
      nil -> # If there is no process with that name, name it thusly
        Process.link(pid)
        {:reply, :ok, Map.put(registry, name, pid)} 
      _ -> # Otherwise, return an error
        {:reply, :error, process_registry}
    end
  end
  
  def handle_call({:whereis, name}, _from, registry) do
    case Map.get(registry, name) do
      nil -> #If there is no process with that name, return nil
        nil
      pid -> #Otherwise, return the pid
        pid
    end
  end
  
  def handle_info({:Exit, pid, _reason}, registry) do
    {:noreply, deregister_pid(registry, pid)}
  end
  
  defp deregister_pid(registry, pid) do
    registry
    |> Enum.reject(fn {_key, registered_process} -> registered_process == pid end)
    |> Enum.into(%{})
  end
end
