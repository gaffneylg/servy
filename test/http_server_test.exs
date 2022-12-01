defmodule HttpServerTest do
  use ExUnit.Case

  alias Servy.HttpServer

  test "accepts a request via a socket and sends a response back" do
    spawn(HttpServer, :start, [4000])

    url = "http://localhost:4000/wildthings"
    {:ok, response} = HTTPoison.get(url)

    parent = self()
    for n <- Enum.to_list(1..5) do
      spawn(fn -> send(parent, {:result, HTTPoison.get(url)}) end)
    end

    for n <- Enum.to_list(1..5) do
      resp = recv()
      confirm_response(resp)
    end

  end

  defp recv() do
    receive do {:result, {:ok, resp}} -> resp end
  end

  defp confirm_response(resp) do
    assert resp.status_code == 200
    assert resp.body == "Bears, Lions, Tigers"
  end
end
