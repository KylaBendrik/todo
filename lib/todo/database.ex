defmodule Todo.Database do
  use GenServer
  
  @db_folder "./persist"
  
  def start do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end
  
  def store(key, data) do
    GenServer.cast(__MODULE__, {:store, key, data})
  end
  
  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  # Callback Functions
  def init(_) do
    File.mkdir_p!(@db_folder)
    workers = (0..2)
    |> Enum.each(fn index -> Map.put(%{}, index, spawn(fn -> Todo.DatabaseWorker.start(@db_folder)end))end)
    
    {:ok, workers}
  end
  
  def handle_cast({:store, key, data}, state) do
    worker = choose_worker(key, state)
    
    Todo.DatabaseWorker.store(worker, key, state)

    {:noreply, state}
  end
  
  def handle_call({:get, key}, _caller, state) do
    worker = choose_worker(key, state)
    
    data = Todo.DatabaseWorker.get(worker, key)
    
    {:reply, data, state}
  end
  
  defp choose_worker(key, state) do
    hashed_key = :erlang.phash2(key, 3)
    state[hashed_key]
  end
  
  defp file_name(key) do
    Path.join(@db_folder, to_string(key))
  end
end
