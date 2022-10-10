defmodule Servy.Handler do

  def handle(request) do
    request
    |> parse()
    |> route()
    |> format_response()
  end

  def parse(request) do
    [method, path, _] =
      request
        |> String.split("\n")
        |> List.first()
        |> String.split(" ")
    %{method: method, path: path, resp_body: "", status: nil}
  end

  def route(conv) do
    route(conv, conv.method, conv.path)
  end


  def route(conv, "GET", "/wildthings") do
    %{ conv | resp_body: "Bears, Lions, Tigers", status: 200}
  end

  def route(conv, "GET", "/bears") do
    %{ conv | resp_body: "Teddy, Paddington, Yogi", status: 200}
  end

  def route(conv, "GET", "/bears/" <> id) do
    %{ conv | resp_body: "Bear #{id}", status: 200}
  end

  def route(conv, method, path) do
    IO.inspect("No function clause matching method type #{method} with path #{path}.")
    %{ conv | resp_body: "#{path} is an invalid path.", status: 404}
  end

  def format_response(conv) do
    """
    HTTP/1.1 #{conv.status} #{status_reason(conv.status)}
    Content-Type: text/html
    Content-Length: #{String.length(conv.resp_body)}

    #{conv.resp_body}
    """
  end

  defp status_reason(code) do
    codes = %{
      200 => "OK",
      201 => "Created",
      401 => "Unauthorized",
      403 => "Forbidden",
      404 => "Not Found",
      500 => "Internal Server Error",
    }
    codes[code]
  end

end


wild_request = """
GET /wildthings HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

wild_response = Servy.Handler.handle(wild_request)
IO.puts wild_response

bears_req = """
GET /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

bears_response = Servy.Handler.handle(bears_req)
IO.puts bears_response

bears1_req = """
GET /bears/11 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

bears1_response = Servy.Handler.handle(bears1_req)
IO.puts bears1_response


bigfoot_req = """
GET /bigfoot HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

bigfoot_response = Servy.Handler.handle(bigfoot_req)
IO.puts bigfoot_response
