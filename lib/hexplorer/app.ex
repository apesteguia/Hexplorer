defmodule Hexplorer.App do
  def run() do
    state =
      %Hexplorer.State{}
      |> Hexplorer.UI.init()
      |> Hexplorer.Sys.getFiles()

    state
    |> Hexplorer.UI.first_tick()
    |> Hexplorer.UI.setTitle()
    |> Hexplorer.UI.draw()
    |> Hexplorer.UI.loop()
  end
end
