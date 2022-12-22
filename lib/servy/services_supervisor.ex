defmodule Servy.ServicesSupervisor do
  use Supervisor

  def start_link(_param) do
    IO.inspect("Starting the services supervisor.")
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      Servy.PledgeServer,
      {Servy.SensorServer, 60} # use tuples to pass in arguments
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

end
