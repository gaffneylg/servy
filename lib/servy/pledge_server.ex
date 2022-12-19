defmodule Servy.PledgeServer do

  use GenServer # injects default implementations of callback module
  @process_name :pledge_server

  defmodule State do
    defstruct cache_size: 3, pledges: []
  end

  # Client interface functions
  def start do
    IO.inspect("Starting the pledge server.")
    GenServer.start(__MODULE__, %State{}, name: @process_name)
  end

  def create_pledge(name, amount) do
    GenServer.call @process_name, {:create_pledge, name, amount}
  end

  def recent_pledges do
    GenServer.call @process_name, :recent_pledges
  end

  def total_pledged do
    GenServer.call @process_name, :total_pledged
  end

  def clear do
    GenServer.cast @process_name, :clear
  end

  def set_cache_size(value) do
    GenServer.cast @process_name, {:set_cache_size, value}
  end

  # Server Callbacks
  def init(state) do
    recent_pledges = fetch_recent_pledges_from_service()
    {:ok, %{state | pledges: recent_pledges}}
  end

  def handle_cast(:clear, state) do
    {:noreply, %{state | pledges: []}}
  end

  def handle_cast({:set_cache_size, value}, state) do
    {:noreply, %{state | cache_size: value}}
  end

  def handle_call(:total_pledged, _from, state) do
    total = Enum.map(state.pledges, &elem(&1, 1)) |> Enum.sum
    {:reply, total, state}
  end

  def handle_call(:recent_pledges, _from, state) do
    {:reply, state.pledges, state}
  end

  def handle_call({:create_pledge, name, amount}, _from, state) do
    {:ok, id} = send_pledge_to_service(name, amount)
    most_recent_pledges = Enum.take(state.pledges, (state.cache_size - 1))
    cached_pledges = [ {name, amount} | most_recent_pledges ]
    new_state = %{state | pledges: cached_pledges}
    {:reply, id, new_state}
  end

  def handle_info(message, state) do
    IO.inspect(message, label: "Can't handle this")
    {:noreply, state}
  end

  defp send_pledge_to_service(name, amount) do
    IO.inspect("Pretending to send #{name}'s pledge of €#{amount} to the pledge service.")
    {:ok, "Pledge - #{:rand.uniform(1000)}"}
  end

  defp fetch_recent_pledges_from_service() do
    # fetch recent pledges to populate it, this would be the way we want it to work.
    [{"michael", 69}, {"kobe", 81}]
  end
end


# alias Servy.PledgeServer

# {:ok, pid} = PledgeServer.start

# send pid, {:stop, "hammertime"}

# PledgeServer.set_cache_size(4)

# IO.inspect PledgeServer.create_pledge("homer", 10)
# PledgeServer.clear
# IO.inspect PledgeServer.create_pledge("moe", 20)
# IO.inspect PledgeServer.create_pledge("lenny", 30)
# IO.inspect PledgeServer.create_pledge("carl", 40)
# IO.inspect PledgeServer.create_pledge("barney", 50)

# IO.inspect PledgeServer.recent_pledges()

# IO.inspect PledgeServer.total_pledged()

# IO.inspect Process.info(pid, :messages)
