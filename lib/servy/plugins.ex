defmodule Servy.Plugins do

  alias Servy.Conv

  @moduledoc """
  Small module to hold helper functions for http request handling.
  """

  @doc """
  Simple function to rewrite a path to a more general accept one.
  """
  def rewrite_path(%Conv{path: "/wildlife"} = conv) do
    %{ conv | path: "/wildthings" }
  end

  def rewrite_path(conv), do: conv


    @doc """
    Will log out any incorrect paths that a request is sent for.
    """
    def track(%Conv{status: 404, path: path} = conv) do
      if Mix.env != :test do
        IO.puts("Warning: #{path} is missing.")
      end
      conv
    end

    def track(conv), do: conv

    def log(%Conv{} = conv) do
      if Mix.env == :dev do
        IO.inspect(conv)
      end
      conv
    end

end
