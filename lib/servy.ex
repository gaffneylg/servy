defmodule Servy do
  use Application
  @moduledoc """
  Initial very VERY basic start for servy project.
  """

  def start(_type, _args) do
    IO.puts("Starting the application.")
    Servy.Supervisor.start_link()
  end
end
