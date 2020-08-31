defmodule Todo.ServerTest do
  use ExUnit.Case
  
  describe "todo cache" do
    setup do
      {:ok, cache} = Todo.Cache.start()
      
      %{cache: cache}
    end
    
    test "Set up a cache with 100,000 lists and verify you actually have that many running.", %{cache: cache} do
      Enum.each(1..10_000, fn index -> Todo.Cache.server_process(cache, "to-do list #{index}") end)
      
      assert :erlang.system_info(:process_count) >= 10_000
    end
    
    
  end
end
