defmodule Servy.BearController do

  alias Servy.Bear
  alias Servy.FileHandler
  alias Servy.Wildthings

  import Servy.View, only: [render: 3]

  @pages_path Path.expand("pages", File.cwd!)

  def index(conv) do
    bears =
      Wildthings.list_bears()
      |> Bear.sort_bears_alphabetically()

    render(conv, "index.html.heex", bears: bears)
  end

  def show(conv, %{"id" => id}) do
    bear = Wildthings.get_bear(id)

    render(conv, "show.html.heex", bear: bear)
  end

  def new(conv) do
    @pages_path
    |> Path.join("form.html")
    |> FileHandler.read_file(conv)
  end

  def create(conv, %{"name" => name, "type" => type} = _params) do
    %{ conv | status: 201,
      resp_body: "Created a bear, #{name} is a #{type} bear!" }
  end

  def delete(conv, _params) do
    # Below was written before checking the answer, turns out we don't wanna delete.
    # %{ conv | status: 201, resp_body: "Deleted bear with id: #{id}!" }
    %{ conv | status: 403, resp_body: "Deleting a bear is forbidden!"}
  end

  def transform_bear_list(bears) do
    Enum.map(bears,
      fn(bear) ->
        "<li>#{bear.name} - #{bear.type}</li>"
      end)
  end
end
