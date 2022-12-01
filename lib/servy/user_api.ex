defmodule Servy.UserApi do

  def query(user_id) do
    "https://jsonplaceholder.typicode.com/users/" <> user_id
    |> HTTPoison.get
    |> handle_resp
  end

  def handle_resp({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    body_map = Poison.Parser.parse!(body, %{})
    city = get_in(body_map, ["address", "city"])
    {:ok, city}
  end

  def handle_resp({:ok, %HTTPoison.Response{status_code: _status, body: body}}) do
    body_map = Poison.Parser.parse!(body, %{})
    message = get_in(body_map, ["message"])
    {:error, message}
  end

  def handle_resp({:error, %HTTPoison.Error{reason: reason}}) do
    {:error, reason}
  end
end
