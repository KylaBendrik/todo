defmodule SimpleRegistry do
  use GenServer
  
  def start_link() do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end
  
  def register(name) do
    GenServer.call(__MODULE__, {:register, name, self()})
  end
  
  def whereis(name) do
    GenServer.call(__MODULE__, {:whereis, name})
  end
  
  # CALLBACK
  
  def init(_) do
    Process.flag(:trap_exit, true)
    {:ok, %{}} # The registry's state should be a map <-
  end
  
  def handle_call({:register, name, pid}, _from, registry) do
    case Map.get(registry, name) do
      nil -> # If there is no process with that name, name it thusly
        Process.link(pid)
        {:reply, :ok, Map.put(registry, name, pid)} 
      _ -> # Otherwise, return an error
        {:reply, :error, registry}
    end
  end
  
  def handle_call({:whereis, name}, _from, registry) do
    {:reply, Map.get(registry, name), registry}
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
