defmodule Todo.Database do
  use GenServer

  # Interface

  def start(db_folder) do
    GenServer.start(__MODULE__, db_folder, name: :database_server)
  end

  def store(key, data) do
    GenServer.cast(:database_server, {:store, key, data})
  end

  def get(key) do
    GenServer.call(:database_server, {:get, key})
  end

  # Server

  def init(db_folder) do
    map = Enum.reduce(0..2, %{}, &(Map.put(&2, &1, elem(Todo.DatabaseWorker.start(db_folder),1))))
    {:ok, map}
  end

  def handle_cast({:store, key, data}, worker_map) do
    Todo.DatabaseWorker.store(get_worker(key, worker_map), key, data)
    {:noreply, worker_map}
  end

  def handle_call({:get, key}, _from, worker_map) do
    data = Todo.DatabaseWorker.get(get_worker(key, worker_map), key)
    {:reply, data, worker_map}
  end

  def get_worker(key, worker_map) do
    Map.get(worker_map, :erlang.phash2(key, 3))
  end
end
