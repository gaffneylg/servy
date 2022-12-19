defmodule Servy.SensorServer do

  @name :sensor_server
  @refresh_interval 5000

  alias Servy.VideoCam

  use GenServer

  # Client interface

  def start do
    GenServer.start(__MODULE__, %{}, name: @name)
  end

  def get_sensor_data do
    GenServer.call(@name, :get_sensor_data)
  end

  # Server callbacks

  def init(_state) do
    initial_state = run_tasks_to_get_sensor_data()
    schedule_refresh(@refresh_interval)
    {:ok, initial_state}
  end

  def handle_call(:get_sensor_data, _from, state) do
    {:reply, state, state}
  end

  def handle_info(:refresh, _state) do
    IO.inspect("Gonna refresh the state now.")
    new_state = run_tasks_to_get_sensor_data()
    schedule_refresh(@refresh_interval)
    {:noreply, new_state}
  end

  def handle_info(message, state) do
    IO.inspect(message, label: "Unexpected message")
    {:noreply, state}
  end

  defp schedule_refresh(interval) do
    Process.send_after(self(), :refresh, interval)
  end


  defp run_tasks_to_get_sensor_data do
    task = Task.async(fn -> Servy.Tracker.get_location("bigfoot") end)

    snaps =
      ["cam-1", "cam-2", "cam-3"]
      |> Enum.map(&Task.async(fn -> VideoCam.get_snapshot(&1) end))
      |> Enum.map(&Task.await/1)

    bigfoot = Task.await(task)
    bigfoot_location = "Lat: " <> bigfoot.lat <> ", Lng: " <> bigfoot.lng <> "."

    %{snapshots: snaps, bigfoot: bigfoot_location}
  end

end
