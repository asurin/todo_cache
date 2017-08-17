defmodule Todo.Server do
  use GenServer

  def start do
    GenServer.start(__MODULE__, Todo.List.new)
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

  def handle_cast({:add_entry, new_entry}, state) do
    {:noreply, Todo.List.add_entry(state, new_entry)}
  end

  def handle_cast({:update_entry, id, updater_fun}, state) do
    {:noreply, Todo.List.update_entry(state, id, updater_fun)}
  end

  def handle_cast({:delete_entry, id}, state) do
    {:noreply, Todo.List.delete_entry(state, id)}
  end

  def handle_call({:entries, date}, _From, state) do
    {:reply, Todo.List.entries(state, date), state}
  end
end