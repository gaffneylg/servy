defmodule Servy.Api.BearController do

  def index(conv) do
    json =
      Servy.Wildthings.list_bears()
      |> Poison.encode!()

    conv = put_resp_content_type(conv, "application/json")
    conv = put_content_length(conv)

    %{conv | status: 200, resp_body: json}
  end

  def format_response_headers(conv) do
    Enum.map(conv.resp_headers,
      fn {key, value} ->
        "#{key}: #{value}\r"
      end)
      |> Enum.sort
      |> Enum.reverse
      |> Enum.join("\n")
  end

  def put_content_length(conv) do
    new_headers = Map.put(conv.resp_headers, "Content-Length", String.length(conv.resp_body))
    %{conv | resp_headers: new_headers}
  end

  defp put_resp_content_type(conv, content_type) do
    new_headers = Map.put(conv.resp_headers, "Content-Type", content_type)
    %{conv | resp_headers: new_headers}
  end
end
