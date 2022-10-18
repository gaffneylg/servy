defmodule Servy.BearController do

  alias Servy.Bear
  alias Servy.FileHandler
  alias Servy.Wildthings

  @pages_path Path.expand("pages", File.cwd!)

  def index(conv) do
    bears =
      Wildthings.list_bears()
      |> Bear.sort_bears_alphabetically()
      |> transform_bear_list()
      |> Enum.join()
    %{ conv | resp_body: "<ul>#{bears}</ul>", status: 200}
  end

  def show(conv, params) do
    bear = Wildthings.get_bear(params["id"])
    %{ conv | resp_body: "<h1>Bear #{bear["id"]}: #{bear["name"]}", status: 200}
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



  def transform_bear_list(bears) do
    Enum.map(bears,
      fn(bear) ->
        "<li>#{bear.name} - #{bear.type}</li>"
      end)
  end

  # defp bear_item(bear) do

  # end
end
