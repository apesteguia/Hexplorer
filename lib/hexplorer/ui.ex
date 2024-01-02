defmodule Hexplorer.UI do
  alias Hexplorer.Sys

  @tick 60

  def init(state) do
    ExNcurses.initscr()
    ExNcurses.noecho()
    ExNcurses.start_color()
    ExNcurses.curs_set(0)
    ExNcurses.cbreak()
    ExNcurses.listen()
    ExNcurses.keypad()
    ExNcurses.refresh()
    ExNcurses.init_pair(1, :blue, :black)
    new = Sys.get_directory_name(state)
    new
  end

  def setTitle(state) do
    new = Sys.get_directory_name(state)
    ExNcurses.attron(1)
    ExNcurses.mvprintw(0, 1, new.current_path)
    ExNcurses.attroff(1)
    ExNcurses.refresh()
    new
  end

  def loop(state) when state.fin == true do
    System.halt(0)
    state
  end

  def loop(state) do
    receive do
      {:ex_ncurses, :key, key} ->
        state |> handle_key(key) |> loop

      :tick ->
        # new = Sys.getFiles(state)
        state |> schedule_next_tick |> draw |> setTitle |> loop
    end
  end

  defp handle_key(state, ?h), do: Sys.go_back(state)
  defp handle_key(state, ?k), do: %{state | idx: state.idx - 1}
  defp handle_key(state, ?j), do: %{state | idx: state.idx + 1}
  defp handle_key(state, ?l), do: Sys.jump(state)
  defp handle_key(state, ?q), do: fin(state)
  defp handle_key(state, _), do: state

  def first_tick(state) do
    Process.send_after(self(), :tick, 1)
    state
  end

  def schedule_next_tick(state) do
    Process.send_after(self(), :tick, @tick)
    state
  end

  defp draw(state) do
    ExNcurses.clear()

    Enum.each(state.dirs, fn filename ->
      index = Enum.find_index(state.dirs, &(&1 == filename))

      if index == state.idx do
        ExNcurses.attron(1)
        ExNcurses.mvprintw(index + 1, 2, filename)
        ExNcurses.attroff(1)
      else
        ExNcurses.mvprintw(index + 1, 2, filename)
      end
    end)

    ExNcurses.refresh()
    state
  end

  def fin(state) do
    ExNcurses.stop_listening()
    ExNcurses.endwin()
    System.halt(0)
    %{state | fin: true}
  end
end
