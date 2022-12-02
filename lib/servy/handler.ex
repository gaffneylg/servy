defmodule Servy.Handler do

  alias Servy.BearController
  alias Servy.Conv
  alias Servy.Fetcher
  alias Servy.FileHandler
  alias Servy.VideoCam
  import Servy.Api.BearController
  import Servy.Parser
  import Servy.Plugins, only: :functions

  @pages_path Path.expand("pages", File.cwd!)

  @moduledoc """
  Simple handler module to accept HTTP requests, process them
  accordingly and respond to the requester with a valid response.
  """

  @doc """
  Transforms the request into a response.
  """
  def handle(request) do
    request
    |> parse
    |> rewrite_path
    |> route
    |> track
    |> put_content_length
    |> format_response
  end

  def route(%Conv{method: "GET", path: "/kaboom"} = _conv) do
    raise "Kaboom!"
  end

  def route(%Conv{method: "GET", path: "/sensors"} = conv) do
    bigfoot_pid = Fetcher.async(fn -> Servy.Tracker.get_location("bigfoot") end)
    snaps =
      ["cam-1", "cam-2", "cam-3"]
      |> Enum.map(&Fetcher.async(fn -> VideoCam.get_snapshot(&1) end))
      |> Enum.map(&Fetcher.recv/1)

    bigfoot = Fetcher.recv(bigfoot_pid)

    %{ conv | status: 200, resp_body: inspect {snaps, bigfoot} }
  end

  def route(%Conv{method: "GET", path: "/hibernate/" <> time} = conv) do
    time |> String.to_integer |> :timer.sleep

    %{ conv | status: 200, resp_body: "Definitely not sleeping!" }
  end

  def route(%Conv{method: "GET", path: "/wildthings"} = conv) do
    %{ conv | resp_body: "Bears, Lions, Tigers", status: 200}
  end

  def route(%Conv{method: "GET", path: "/about"} = conv) do
    @pages_path
    |> Path.join("about.html")
    |> FileHandler.read_file(conv)
  end

  def route(%Conv{method: "GET", path: "/pages/" <> page} = conv) do
    @pages_path
    |> Path.join("#{page}.html")
    |> FileHandler.read_file(conv)
  end

  def route(%Conv{method: "GET", path: "/api/bears"} = conv) do
    Servy.Api.BearController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/bears"} = conv) do
    BearController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/bears/new"} = conv) do
    BearController.new(conv)
  end

  def route(%Conv{method: "GET", path: "/bears/" <> id} = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.show(conv, params)
  end

  def route(%Conv{method: "POST", path: "/bears"} = conv) do
    BearController.create(conv, conv.params)
  end

  def route(%Conv{method: "DELETE", path: "/bears/" <> id} = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.delete(conv, params)
  end

  def route(%Conv{method: "POST", path: "/api/bears"} = conv) do
    Servy.Api.BearController.create(conv)
  end

  def route(%Conv{path: path} = conv) do
    # IO.inspect("No function clause matching with path #{path}.")
    %{ conv | resp_body: "#{path} is an invalid path.", status: 404}
  end

  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}\r
    #{format_response_headers(conv)}
    \r
    #{conv.resp_body}
    """
  end
end


# ==============================================================================
# Requests below are now in the form of tests, if wanted to run below in iex,
# will need to edit and make compatible with \r\n in newer code.
# ==============================================================================

# post_request = """
# POST /bears HTTP/1.1
# Host: example.com
# User-Agent: ExampleBrowser/1.0
# Accept: */*
# Content-Type: application/x-www-form-urlencoded
# Content-Length: 21

# name=Baloo&type=Brown
# """

# Servy.Handler.handle(post_request)
# |> IO.puts

# wildthing_request = """
# GET /wildthings HTTP/1.1
# Host: example.com
# User-Agent: ExampleBrowser/1.0
# Accept: */*

# """

# Servy.Handler.handle(wildthing_request)
# |> IO.puts

# wildlife_request = """
# GET /wildthings HTTP/1.1
# Host: example.com
# User-Agent: ExampleBrowser/1.0
# Accept: */*

# """

# Servy.Handler.handle(wildlife_request)
# |> IO.puts

# bears_req = """
# GET /bears HTTP/1.1
# Host: example.com
# User-Agent: ExampleBrowser/1.0
# Accept: */*

# """

# Servy.Handler.handle(bears_req)
# |> IO.puts

# bears1_req = """
# GET /bears/6 HTTP/1.1
# Host: example.com
# User-Agent: ExampleBrowser/1.0
# Accept: */*

# """

# Servy.Handler.handle(bears1_req)
# |> IO.puts

# bears_new_req = """
# GET /bears/new HTTP/1.1
# Host: example.com
# User-Agent: ExampleBrowser/1.0
# Accept: */*

# """

# Servy.Handler.handle(bears_new_req)
# |> IO.puts

# delete_request = """
# DELETE /bears/1 HTTP/1.1
# Host: example.com
# User-Agent: ExampleBrowser/1.0
# Accept: */*

# """

# Servy.Handler.handle(delete_request)
# |> IO.puts

# bigfoot_req = """
# GET /bigfoot HTTP/1.1
# Host: example.com
# User-Agent: ExampleBrowser/1.0
# Accept: */*

# """

# Servy.Handler.handle(bigfoot_req)
# |> IO.puts

# about_req = """
# GET /about HTTP/1.1
# Host: example.com
# User-Agent: ExampleBrowser/1.0
# Accept: */*

# """

# Servy.Handler.handle(about_req)
# |> IO.puts

# faq_req = """
# GET /pages/faq HTTP/1.1
# Host: example.com
# User-Agent: ExampleBrowser/1.0
# Accept: */*

# """

# Servy.Handler.handle(faq_req)
# |> IO.puts
