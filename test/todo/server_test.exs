defmodule Todo.ServerTest do
  use ExUnit.Case
  
  describe "todo server" do
    setup do
      {:ok, server} = Todo.Server.start()
      
      %{server: server}
    end
    
    test "to-do operations", %{server: server} do
      Todo.Server.add_entry(server, %{date: ~D[2018-12-19], title: "Dentist"})
      entries = Todo.Server.entries(server, ~D[2018-12-19])
      
      assert [%{date: ~D[2018-12-19], title: "Dentist"}] = entries
    end
    
    
  end
end
