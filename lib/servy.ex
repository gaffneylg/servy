defmodule Servy do
  @moduledoc """
  Initial very VERY basic start for servy project.
  """

  def hello(name) do
    "Hello, #{name}!"
  end
end

IO.puts(Servy.hello("Mike"))
