defmodule Servy.PledgeServer do


  def listen_loop(state) do
    IO.inspect "Waiting on a message"

    receive do
      {:create_pledge, name, amount} ->
        # TODO: implement proper state here
        # cache = state.cache
        new_state = [ {name, amount} | state]
        {:ok, id} = send_pledge_to_service(name, amount)
        IO.inspect("#{name} pledged #{amount}.")
        listen_loop(new_state)
      {sender, :recent_pledges} ->
        # pledges = recent_pledges()
        send sender, {:response, state}
        IO.inspect(sender, label: "sender")
        listen_loop(state)
    end

  end

  def create_pledge(name, amount) do
    case send_pledge_to_service(name, amount) do
      {:ok, id} ->
        IO.inspect("Succesfully lodged #{name}'s pledge, thank you.")
        [{name, amount}]
      {:error, _reason} ->
        IO.inspect("Error occurred while lodging #{name}'s pledge.")
    end
  end

  def recent_pledges() do
    # fun to return the 3 most recent pledges from cache
  end

  defp send_pledge_to_service(name, amount) do
    IO.inspect("Pretending to send #{name}'s pledge of €#{amount} to the service provider.")
    {:ok, "Pledge - #{:rand.uniform(1000)}"}
  end
end
