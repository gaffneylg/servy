defmodule Servy.Parser do

  alias Servy.Conv

  def parse(request) do
    [query_string, param_string] = String.split(request, "\r\n\r\n")

    [request_line | header_lines] = String.split(query_string, "\r\n")

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


  @doc """

  Parses the given param string of the form 'key1=value1&key2=value2'
  into a map with corresponding keys and values

  ## Examples
    iex> params_string = "name=Baloo&type=Brown"
    iex> Servy.Parser.parse_params("application/x-www-form-urlencoded", params_string)
    %{"name" => "Baloo", "type" => "Brown"}
    iex> Servy.Parser.parse_params("multipart/form-data", params_string)
    %{}

  """

  def parse_params("application/x-www-form-urlencoded", param_string) do
    param_string
      |> String.trim()
      |> URI.decode_query()
  end

  def parse_params("application/json", param_string) do
    Poison.Parser.parse!(param_string)
  end

  def parse_params(_content_type, _param_string), do: %{}

  def parse_headers([head | tail], headers) do
    [key, value] = String.split(head, ": ")
    headers = Map.put(headers, key, value)
    parse_headers(tail, headers)
  end

  def parse_headers([], headers), do: headers
end
