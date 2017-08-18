defmodule Todo.Server do
  use GenServer

  # Interface

  def start_link(name) do
    IO.puts("Starting server #{name}")
    GenServer.start_link(__MODULE__, name, name: via_tuple(name))
  end

  def add_entry(pid, new_entry) do
    GenServer.cast(pid, {:add_entry, new_entry})
  end

  def update_entry(pid, id, updater_fun) do
    GenServer.cast(pid, {:update_entry, id, updater_fun})
  end

  def delete_entry(pid, id) do
    GenServer.cast(pid, {:delete_entry, id})
  end

  def entries(pid, date) do
    GenServer.call(pid, {:entries, date})
  end

  # Server

  def init(todo_list_name) do
    {:ok, {todo_list_name, Todo.Database.get(todo_list_name) || Todo.List.new}}
  end

  def handle_cast({:add_entry, new_entry}, {todo_list_name, todo_list}) do
    new_state = Todo.List.add_entry(todo_list, new_entry)
    Todo.Database.store(todo_list_name, new_state)
    {:noreply, {todo_list_name, new_state}}
  end

  def handle_cast({:update_entry, id, updater_fun}, {todo_list_name, todo_list}) do
    {:noreply, {todo_list_name, Todo.List.update_entry(todo_list, id, updater_fun)}}
  end

  def handle_cast({:delete_entry, id}, {todo_list_name, todo_list}) do
    {:noreply, {todo_list_name, Todo.List.delete_entry(todo_list, id)}}
  end

  def handle_call({:entries, date}, _from, {todo_list_name, todo_list}) do
    {:reply, Todo.List.entries(todo_list, date), {todo_list_name, todo_list}}
  end

  defp via_tuple(name) do
    {:via, Todo.ProcessRegistry, {:todo_server, name}}
  end

  def whereis(name) do
    Todo.ProcessRegistry.whereis_name({:todo_server, name})
  end
end
