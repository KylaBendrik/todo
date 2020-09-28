defmodule Todo.Server do
  use Agent, restart: :temporary

  def start_link(name) do
    Agent.start_link(
      fn ->
        IO.puts("Starting to-do server for #{name}.")
        {name, Todo.Database.get(name) || Todo.List.new()}
      end,
      name: via_tuple(name)
    )
  end

  def add_entry(todo_server, new_entry) do
    Agent.cast(todo_server, fn {name, todo_list} -> 
      new_list = Todo.List.add_entry(todo_list, new_entry)
      Todo.Database.store(name, new_list)
      {name, new_list}
    
    end)
  end

  def entries(todo_server, date) do
    Agent.get(
      todo_server,
      fn {_name, todo_list} -> Todo.List.entries(todo_list, date) end
    )
  end
  
  @expiry_idle_timeout :timer.seconds(10)

<<<<<<< HEAD
  # @impl GenServer
  # def init(name) do
  #   {:ok, {name, Todo.Database.get(name) || Todo.List.new()}}
  # end

  # @impl GenServer
  # def handle_cast({:add_entry, new_entry}, {name, todo_list}) do
  #   new_list = Todo.List.add_entry(todo_list, new_entry)
  #   Todo.Database.store(name, new_list)
  #   {:noreply, {name, new_list}}
  # end

  # @impl GenServer
  # def handle_call({:entries, date}, _, {name, todo_list}) do
  #   {
  #     :reply,
  #     Todo.List.entries(todo_list, date),
  #     {name, todo_list}
  #   }
  # end
=======
  @impl GenServer
  def init(name) do
    IO.puts("Starting to-do server for #{name}.")
    {
      :ok, 
      {name, Todo.Database.get(name) || Todo.List.new()},
      @expiry_idle_timeout
    }
  end

  @impl GenServer
  def handle_cast({:add_entry, new_entry}, {name, todo_list}) do
    new_list = Todo.List.add_entry(todo_list, new_entry)
    Todo.Database.store(name, new_list)
    {
      :noreply, 
      {name, new_list}, 
      @expiry_idle_timeout
    }
  end

  @impl GenServer
  def handle_call({:entries, date}, _, {name, todo_list}) do
    {
      :reply,
      Todo.List.entries(todo_list, date),
      {name, todo_list}, 
      @expiry_idle_timeout
    }
  end
>>>>>>> todo_cache_expiry
  
  @impl GenServer
  def handle_info(:timeout, {name, todo_list}) do
    IO.puts("Stopping to-do server for #{name}")
    {:stop, :normal, {name, todo_list}}
  end
  
  defp via_tuple(name) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, name})
  end
end
