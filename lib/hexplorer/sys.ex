defmodule Hexplorer.Sys do
  def getFiles(state) do
    case File.ls() do
      {:ok, dirs} -> %{state | dirs: dirs}
      _ -> %{state | dirs: []}
    end
  end

  def get_directory_name(state) do
    case File.cwd() do
      {:ok, name} -> %{state | current_path: name}
      _ -> %{state | current_path: "NO DATA"}
    end

    state
  end

  def remove(list) do
    List.delete_at(list, length(list) - 1)
  end

  def go_back(state) do
    current_path =
      case File.cwd() do
        {:ok, path} ->
          path |> String.split("/") |> remove() |> Enum.join("/") |> File.cd!()
          path

        _ ->
          state.current_path
      end

    dirs = getFiles(state)

    %{dirs | current_path: current_path}
  end
end
