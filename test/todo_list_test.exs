defmodule TodoListTest do
  use ExUnit.Case, async: true

  test "Starts with an auto_id of 1" do
    assert(Todo.List.new.auto_id == 1)
  end
end
