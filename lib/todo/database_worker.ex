defmodule Todo.DatabaseWorker do
  use GenServer
  
  @db_folder "./persist"
  
  def start(db_folder) do
    GenServer.start(__MODULE__, db_folder)
  end
  
  def store(worker, key, data) do
    GenServer.cast(worker, {:store, key, data})
  end
  
  def get(worker, key, caller) do
    GenServer.call(worker, {:get, key})
  end

  # Callback Functions
  def init(db_folder) do
    File.mkdir_p!(db_folder)
    {:ok, nil}
  end
  
  def handle_cast({:store, key, data}, state) do
        key
      |> file_name()
      |> File.write!(:erlang.term_to_binary(data))

    {:noreply, state}
  end
  
  def handle_call({:get, key}, caller, state) do
    spawn(fn ->
      data = case File.read(file_name(key)) do
        {:ok, contents} -> :erlang.binary_to_term(contents)
        _-> nil
      end 
      GenServer.reply(caller, data)
    end)
    
    
      
      {:noreply, state}
  end
  
  defp file_name(key) do
    Path.join(@db_folder, to_string(key))
  end
end
