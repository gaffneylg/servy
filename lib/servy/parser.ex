defmodule Servy.Parser do

  alias Servy.Conv

  def parse(request) do
    [query_string, param_string] = String.split(request, "\n\n")

    [request_line | _header_lines] = String.split(query_string, "\n")

    [method, path, _] = String.split(request_line, " ")

    params = parse_params(param_string)

    %Conv{
      method: method,
      path: path,
      params: params
    }
  end


  def parse_params(param_string) do
    param_string
      |> String.trim()
      |> URI.decode_query()
  end
end
