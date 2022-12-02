defmodule HttpServerTest do
  use ExUnit.Case

  alias Servy.HttpServer

  test "accepts a request via a socket and sends a response back" do
    spawn(HttpServer, :start, [4000])
    parent = self()

    url1 = "http://localhost:4000/wildthings"
    url2 = "http://localhost:4000/bears"
    urls = [url1, url2]

    for url <- urls do
      {:ok, resp} =
        Task.async(fn -> HTTPoison.get(url) end)
        |> Task.await()
      confirm_response(resp)
    end
  end

  defp recv() do
    receive do {:result, {:ok, resp}} -> resp end
  end

  defp confirm_response(resp) do
    assert resp.status_code == 200
  end
end
