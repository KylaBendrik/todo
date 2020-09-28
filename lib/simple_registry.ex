defmodule SimpleRegistry do
  use GenServer
  
  def start_link() do
    GenServer.start_link(SimpleRegistry, __MODULE__, name: __MODULE__)
  end
  
  def register(name) do
    GenServer.call(__MODULE__, name)
  end
  
  def init(init_arg) do
    {:ok, init_arg}
  end
  
  def handle_call({:instruction, data}, _from, list_or_library) do
    :ok
  end
end
