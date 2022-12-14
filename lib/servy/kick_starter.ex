defmodule Servy.KickStarter do
  use GenServer

  @name :kickstarter

  defmodule State do
    defstruct http_server: nil
  end

  # client functions

  def start_link(_param) do
    IO.inspect("Starting the kick starter")
    GenServer.start_link(__MODULE__, %State{}, name: @name)
  end

  def get_server() do
    GenServer.call(@name, :get_server_info)
  end

  # GenServer functions

  def init(state) do
    Process.flag(:trap_exit, true)
    http_server = start_server()
    state = %{state | http_server: http_server}
    {:ok, state}
  end

  def handle_call(:get_server_info, _from, state) do
    {:reply, state.http_server, state}
  end

  def handle_info({:EXIT, _pid_killed, message}, _state) do
    IO.inspect(message, label: "Process exited with reason")
    http_server = start_server()
    new_state = %State{http_server: http_server}
    {:noreply, new_state}
  end

  defp start_server() do
    IO.inspect("Starting the HTTP server")
    port = Application.get_env(:servy, :port)
    server_pid = spawn_link(Servy.HttpServer, :start, [port])
    Process.register(server_pid, :http_server)
    server_pid
  end
end
