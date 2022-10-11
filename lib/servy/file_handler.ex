defmodule Servy.FileHandler do

  def read_file(file_path, conv) do
    case File.read(file_path) do
      {:ok, file_contents} ->
        %{ conv | resp_body: file_contents, status: 200}
      {:error, :enoent} ->
        %{ conv | resp_body: "File does not exist.", status: 404}
      {:error, reason} ->
        %{ conv | resp_body: reason, status: 404}
    end
  end
end
