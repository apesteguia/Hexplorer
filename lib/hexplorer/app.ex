defmodule Hexplorer.App do
  def run() do
    state =
      %Hexplorer.State{}
      |> Hexplorer.UI.init()
      |> Hexplorer.Sys.getFiles()

    state
    |> Hexplorer.UI.setTitle()
    |> Hexplorer.UI.first_tick()
    |> Hexplorer.UI.loop()
    |> Hexplorer.UI.fin()
  end
end
