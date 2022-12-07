defmodule Servy.PledgeServer do

  @process_name :pledge_server

  def start do
    IO.inspect("Starting the pledge server.")
    pid = spawn(__MODULE__, :listen_loop, [[]])
    Process.register(pid, @process_name)
    pid
  end

  def listen_loop(state) do
    receive do
      {sender, :create_pledge, name, amount} ->
        case send_pledge_to_service(name, amount) do
          {:ok, id} ->
            IO.inspect("Succesfully lodged #{name}'s pledge, thank you.")
            most_recent = Enum.take(state, 2)
            new_state = [ {name, amount} | most_recent ]
            send(sender, {:response, id})
            listen_loop(new_state)
          {:error, _reason} ->
            IO.inspect("Error occurred while lodging #{name}'s pledge.")
            listen_loop(state)
          end
      {sender, :recent_pledges} ->
        send(sender, {:response, state})
        listen_loop(state)
    end

  end

  def create_pledge(name, amount) do
    send(@process_name, {self(), :create_pledge, name, amount})
    receive do
      {:response, status} ->
        status
    end
  end

  def recent_pledges do
    send(@process_name, {self(), :recent_pledges})
    receive do
      {:response, pledges} ->
        pledges
    end
  end

  defp send_pledge_to_service(name, amount) do
    IO.inspect("Pretending to send #{name}'s pledge of €#{amount} to the pledge service.")
    {:ok, "Pledge - #{:rand.uniform(1000)}"}
  end
end


alias Servy.PledgeServer

pid = PledgeServer.start

IO.inspect PledgeServer.create_pledge("homer", 10)
IO.inspect PledgeServer.create_pledge("moe", 20)
IO.inspect PledgeServer.create_pledge("lenny", 30)
IO.inspect PledgeServer.create_pledge("carl", 40)
IO.inspect PledgeServer.create_pledge("barney", 50)

IO.inspect PledgeServer.recent_pledges()
