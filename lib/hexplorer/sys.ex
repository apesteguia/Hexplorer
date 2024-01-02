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

  def jump(state) do
    current = Enum.at(state.dirs, state.idx)
    jumped = state.current_path <> "/" <> current

    File.cd!(jumped)
    new = getFiles(state)

    %{new | current_path: jumped, idx: 0}
  end

  def go_back(state) do
    current_path =
      case File.cwd() do
        {:ok, path} ->
          parent = Path.dirname(path)

          File.cd!(parent)

          parent

        _ ->
          state.current_path
      end

    dirs = getFiles(state)

    %{dirs | current_path: current_path, idx: 0}
  end
end
