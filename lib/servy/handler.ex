defmodule Servy.Handler do

  def handle(request) do
    request
    |> parse()
    |> rewrite_path()
    |> route()
    |> track()
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

  def rewrite_path(%{path: "/wildlife"} = conv) do
    %{ conv | path: "/wildthings" }
  end

  def rewrite_path(conv), do: conv

  def route(%{method: "GET", path: "/wildthings"} = conv) do
    %{ conv | resp_body: "Bears, Lions, Tigers", status: 200}
  end

  def route(%{method: "GET", path: "/bears"} = conv) do
    %{ conv | resp_body: "Teddy, Paddington, Yogi", status: 200}
  end

  def route(%{method: "GET", path: "/bears/" <> id} = conv) do
    %{ conv | resp_body: "Bear #{id}", status: 200}
  end

  def route(%{path: path} = conv) do
    IO.inspect("No function clause matching with path #{path}.")
    %{ conv | resp_body: "#{path} is an invalid path.", status: 404}
  end

  def track(%{status: 404, path: path} = conv) do
    IO.puts("Warning: #{path} is missing.")
    conv
  end

  def track(conv), do: conv

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


wildthing_request = """
GET /wildthings HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

wildthing_response = Servy.Handler.handle(wildthing_request)
IO.puts wildthing_response

wildlife_request = """
GET /wildthings HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

wildlife_response = Servy.Handler.handle(wildlife_request)
IO.puts wildlife_response

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
