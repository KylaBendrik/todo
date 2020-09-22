defmodule Todo.ProcessRegistry do
  
  # Forwards to the Registry module to start a unique registry.
  def start_link do
    Registry.start_link(keys: :unique, name: __MODULE__)
  end
  
  
  # can be used by other modules, such as Todo.DatabaseWorker, to create the appropriate via_tuple that registers a process with this registry.
  def via_tuple(key) do
    {:via, Registry, {__MODULE__, key}}
  end
  
  def child_spec(_) do
    Supervisor.child_spec(
      Registry,
      id: __MODULE__,
      start: {__MODULE__, :start_link, []}
    )
  end
end
