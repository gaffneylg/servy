defmodule Servy.KickStarter do
  use GenServer

  @name :kickstarter

  def start do
    IO.inspect("Starting the kick starter")
    GenServer.start(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    Process.flag(:trap_exit, true)
    {:ok, start_server()}
  end


  def handle_info({:EXIT, _pid_killed, message}, _state) do
    IO.inspect(message, label: "Process exited with reason")
    {:noreply, start_server()}
  end

  defp start_server() do
    IO.inspect("Starting the HTTP server")
    server_pid = spawn_link(Servy.HttpServer, :start, [4000])
    Process.register(server_pid, :http_server)
    server_pid
  end
end
