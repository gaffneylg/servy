defmodule Servy.SensorServer do

  @name :sensor_server

  alias Servy.VideoCam

  use GenServer

  defmodule State do
    defstruct sensor_data: %{},
              refresh_interval: :timer.minutes(60)
  end

  # Client interface

  def start_link(interval) do
    IO.inspect("Starting the sensor server with #{interval} minutes between refresh.")
    GenServer.start_link(__MODULE__, %State{refresh_interval: :timer.minutes(interval)}, name: @name)
  end

  def get_sensor_data do
    GenServer.call(@name, :get_sensor_data)
  end

  def set_refresh_interval(new_interval_ms) do
    GenServer.cast(@name, {:refresh_interval, new_interval_ms})
  end

  # Server callbacks

  def init(state) do
    sensor_info = run_tasks_to_get_sensor_data()
    schedule_refresh(state.refresh_interval)
    {:ok, %State{state | sensor_data: sensor_info}}
  end

  def handle_call(:get_sensor_data, _from, state) do
    {:reply, state.sensor_data, state}
  end

  def handle_cast({:refresh_interval, new_interval}, state) do
    new_state = %State{state | refresh_interval: new_interval}
    {:noreply, new_state}
  end

  def handle_info(:refresh, state) do
    IO.inspect("Gonna refresh the state now.")
    new_state = run_tasks_to_get_sensor_data()
    schedule_refresh(state.refresh_interval)
    {:noreply, %State{state | sensor_data: new_state}}
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
