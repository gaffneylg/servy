defmodule Servy.Wildthings do
  alias Servy.Bear

  def list_bears() do
    [
      %Bear{id: 1, name: "Yogi", type: "Brown"},
      %Bear{id: 2, name: "Paddington", type: "Brown"},
      %Bear{id: 3, name: "Teddy", type: "Polar", hibernating: true},
      %Bear{id: 4, name: "Baloo", type: "Brown", hibernating: true},
      %Bear{id: 5, name: "Winnie", type: "Honey"},
      %Bear{id: 6, name: "Little John", type: "Brown"},
    ]
  end

  def get_bear(id)
    when is_integer(id) do
    Enum.find(list_bears(), fn(bear) -> bear.id == id end)
  end

  def get_bear(id)
    when is_binary(id) do
      id |> String.to_integer() |> get_bear()
  end
end
