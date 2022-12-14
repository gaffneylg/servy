defmodule Servy.GenericServer do
  def start(callback_module, initial_state, name) do
    pid = spawn(__MODULE__, :listen_loop, [initial_state, callback_module])
    Process.register(pid, name)
    pid
  end

  def call(pid, message) do
    send pid, {:call, self(), message}

    receive do {:response, response} -> response end
  end

  def cast(pid, message) do
    send pid, {:cast, message}
  end

  def listen_loop(state, callback_module) do
    receive do
      {:call, sender, message} when is_pid(sender) ->
        {response, new_state} = callback_module.handle_call(message, state)
        send sender, {:response, response}
        listen_loop(new_state, callback_module)
      {:cast, message} ->
        new_state = callback_module.handle_cast(message, state)
        listen_loop(new_state, callback_module)
      unexpected ->
        IO.puts "Unexpected messaged: #{inspect unexpected}"
        listen_loop(state, callback_module)
    end
  end
end


defmodule Servy.PledgeServerOld do

  @process_name :pledge_server_old

  alias Servy.GenericServer

  # Client interface functions
  def start do
    IO.inspect("Starting the pledge server.")
    GenericServer.start(__MODULE__, [], @process_name)
  end

  def create_pledge(name, amount) do
    GenericServer.call @process_name, {:create_pledge, name, amount}
  end

  def recent_pledges do
    GenericServer.call @process_name, :recent_pledges
  end

  def total_pledged do
    GenericServer.call @process_name, :total_pledged
  end

  def clear do
    GenericServer.cast @process_name, :clear
  end

  # Server Callbacks
  def handle_cast(:clear, _state) do
    []
  end

  def handle_call(:total_pledged, state) do
    total = Enum.map(state, &elem(&1, 1)) |> Enum.sum
    {total, state}
  end

  def handle_call(:recent_pledges, state) do
    {state, state}
  end

  def handle_call({:create_pledge, name, amount}, state) do
    {:ok, id} = send_pledge_to_service(name, amount)
    most_recent_pledges = Enum.take(state, 2)
    new_state = [ {name, amount} | most_recent_pledges ]
    {id, new_state}
  end

  defp send_pledge_to_service(name, amount) do
    IO.inspect("Pretending to send #{name}'s pledge of ???#{amount} to the pledge service.")
    {:ok, "Pledge - #{:rand.uniform(1000)}"}
  end
end


# alias Servy.PledgeServerOld

# pid = PledgeServerOld.start

# send pid, {:stop, "hammertime"}

# IO.inspect PledgeServerOld.create_pledge("homer", 10)
# IO.inspect PledgeServerOld.create_pledge("moe", 20)
# IO.inspect PledgeServerOld.create_pledge("lenny", 30)
# IO.inspect PledgeServerOld.create_pledge("carl", 40)
# IO.inspect PledgeServerOld.create_pledge("barney", 50)

# IO.inspect PledgeServerOld.recent_pledges()

# IO.inspect PledgeServerOld.total_pledged()

# IO.inspect Process.info(pid, :messages)
