defmodule Hexplorer.UI do
  alias Hexplorer.Sys

  @tick 200

  def init(state) do
    ExNcurses.initscr()
    win = ExNcurses.newwin(state.height, state.width, 0, 0)
    ExNcurses.noecho()
    ExNcurses.start_color()
    ExNcurses.curs_set(0)
    ExNcurses.cbreak()
    ExNcurses.listen()
    ExNcurses.keypad()
    ExNcurses.wborder(win)
    ExNcurses.refresh()
    ExNcurses.wrefresh(win)
    %{state | win: win}
  end

  def setTitle(state) do
    new = Sys.get_directory_name(state)
    ExNcurses.mvprintw(1, 1, new.current_path)
    new
  end

  def loop(%{fin: true} = state) do
    fin(state)
  end

  def loop(state) do
    receive do
      {:ex_ncurses, :key, key} ->
        state |> handle_key(key) |> loop

      :tick ->
        # new = Sys.getFiles(state)
        state |> schedule_next_tick |> setTitle() |> draw |> loop
    end
  end

  defp handle_key(state, ?h), do: Sys.go_back(state)
  defp handle_key(state, ?k), do: %{state | dirs: []}
  defp handle_key(state, ?j), do: %{state | dirs: []}
  defp handle_key(state, ?l), do: %{state | dirs: []}
  defp handle_key(state, _), do: state

  def first_tick(state) do
    Process.send_after(self(), :tick, 1)
    state
  end

  def schedule_next_tick(state) do
    Process.send_after(self(), :tick, @tick)
    state
  end

  def draw(state) do
    ExNcurses.clear()
    ExNcurses.wclear(state.win)

    Enum.each(state.dirs, fn filename ->
      index = Enum.find_index(state.dirs, &(&1 == filename))
      ExNcurses.mvprintw(index + 1, 2, filename)
    end)

    ExNcurses.wborder(state.win)
    ExNcurses.wrefresh(state.win)
    ExNcurses.refresh()
    state
  end

  def fin(state) do
    ExNcurses.stop_listening()
    ExNcurses.endwin()
    %{state | fin: true}
  end
end
