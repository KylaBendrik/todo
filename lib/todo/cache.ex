defmodule Todo.Cache do
  use GenServer
  # interface functions
  def start do
    GenServer.start(__MODULE__, nil)
  end
  def server_process(cache_pid, todo_list_name) do
    GenServer.call(cache_pid, {:server_process, todo_list_name})
  end
  
  # callback functions
  def init(_) do
    Todo.Database.start()
    {:ok, %{}}
  end
  
  def handle_call({:server_process, todo_list_name}, _, todo_servers) do
    case Map.fetch(todo_servers, todo_list_name) do
      {:ok, todo_server} -> 
        # if there is a return value for the key given, return that value
        {:reply, todo_server, todo_servers}
      :error -> 
        {:ok, new_server} = Todo.Server.start(todo_list_name)
        # if there is no return value, create a new server and add it into the list
        {:reply, new_server, Map.put(todo_servers, todo_list_name, new_server)}
    end
  end
end
