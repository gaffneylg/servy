defmodule Servy.PledgeServer do


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
