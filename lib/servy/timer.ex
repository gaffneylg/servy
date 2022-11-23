defmodule Servy.Timer do
  @moduledoc """
  Simple timer module to print out a reminder for a user
  after the given time(in seconds) has passed.
  """

  def remind(momento, seconds) do
    spawn(fn ->
      seconds * 1000 |> :timer.sleep
      IO.puts(momento)
    end)
  end
end
