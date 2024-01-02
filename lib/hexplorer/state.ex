defmodule Hexplorer.State do
  defstruct width: 50,
            height: 40,
            win: nil,
            dirs: [],
            current_path: "",
            idx: 0,
            fin: false
end
