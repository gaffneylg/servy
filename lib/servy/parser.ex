defmodule Servy.Parser do

  alias Servy.Conv

  def parse(request) do
    [query_string, param_string] = String.split(request, "\n\n")

    [request_line | header_lines] = String.split(query_string, "\n")

    [method, path, _] = String.split(request_line, " ")

    headers = parse_headers(header_lines, %{})

    params = parse_params(headers["Content-Type"], param_string)

    %Conv{
      method: method,
      path: path,
      params: params,
      headers: headers
    }
  end


  def parse_params("application/x-www-form-urlencoded", param_string) do
    param_string
      |> String.trim()
      |> URI.decode_query()
  end

  def parse_params(_content_type, _param_string), do: %{}

  def parse_headers([head | tail], headers) do
    [key, value] = String.split(head, ": ")
    headers = Map.put(headers, key, value)
    parse_headers(tail, headers)
  end

  def parse_headers([], headers), do: headers
end
