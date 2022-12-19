defmodule Servy.VideoCam do
  @doc """
  Simulates sending an external API request
  to get a snapshot image from a video camera.
  """

  alias Servy.UserApi

  def get_snapshot(camera_name) do
    # Example API call to fetch fake user's info.
    case UserApi.query("2") do
      {:ok, city} ->
        # IO.inspect(city, label: "User is from")
        city
      {:error, error} ->
        "Whoops! #{error}"
    end

    # sample slow query
    :timer.sleep(500)

    "#{camera_name}-snapshot-#{:rand.uniform(1000)}.jpg"
  end
end
