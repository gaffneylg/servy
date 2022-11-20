defmodule Servy.HttpServer do

  def start(port) when is_integer(port) and port > 1023 do

    # Creates a socket to listen for client connections,
    {:ok, listen_sock} =
      :gen_tcp.listen(port, [:binary, packet: :raw, active: false, reuseaddr: true])
      # binary is to open the socket in binary mode and deliver data as binaries
      # packet: :raw - deliver the entire binary without any packer handling
      # active: false - receive data when we're ready by calling gen_tcp:recv
      # reuseaddr: true - allows reusing the address if listener crashes

    accept_loop(listen_sock)
  end


  def accept_loop(listen_sock) do
    IO.puts("Waiting to accept client connection.\n")
    {:ok, client_sock} = :gen_tcp.accept(listen_sock)
    IO.puts("Connection accepted.\n")
    serve(client_sock)
    accept_loop(listen_sock)
  end

  @doc """
  Receives the request on the client_socket and
  sends a response back over that socket.
  """
  def serve(client_sock) do
    client_sock
    |> read_request
    |> Servy.Handler.handle
    |> write_response(client_sock)
  end

  @doc """
  Receives a request on the client socket.
  """
  def read_request(client_socket) do
    {:ok, req} = :gen_tcp.recv(client_socket, 0)
    IO.puts("Request received.\n")
    IO.inspect(req, label: "Request")
    req
  end

  @doc """
  Generates a valid HTTP response to send to the client.
  """
  def generate_response(_request) do
    """
    HTTP/1.1 200 OK\r
    Content-Type: text/html\r
    Content-Length: 12\r
    \r
    Hello world!
    """
  end

  @doc """
  Sends the response back over the socket to the client.
  """
  def write_response(response, client_socket) do
    :ok = :gen_tcp.send(client_socket, response)
    IO.puts("Sent response.\n")
    IO.inspect(response, label: "Response")
    :ok = :gen_tcp.close(client_socket)
  end

end
