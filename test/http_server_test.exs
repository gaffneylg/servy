defmodule HttpServerTest do
  use ExUnit.Case

  alias Servy.HttpServer

  test "accepts a request via a socket and sends a response back" do
    spawn(HttpServer, :start, [4000])

    url = "http://localhost:4000/wildthings"
    {:ok, response} = HTTPoison.get(url)

    assert response.status_code == 200
    assert response.body == "Bears, Lions, Tigers"
  end
end
