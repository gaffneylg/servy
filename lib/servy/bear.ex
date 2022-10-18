defmodule Servy.Bear do
  defstruct [
    id: nil,
    name: "",
    type: "",
    hibernating: false
  ]

  def sort_bears_alphabetically(bears) do
    Enum.sort(bears,
      fn(bear1, bear2) ->
        bear1.name <= bear2.name
      end)
  end
end
