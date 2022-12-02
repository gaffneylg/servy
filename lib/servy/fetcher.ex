defmodule Servy.Fetcher do

  alias Servy.VideoCam

  def async(fun) do
    parent = self()
    spawn(fn -> send(parent, {self(), :result, fun.()}) end)
  end


  def recv(pid) do
    receive do
      {^pid, :result, package} ->
        package
    end
  end
end
