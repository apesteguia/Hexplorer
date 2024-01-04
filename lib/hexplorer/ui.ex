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
    ExNcurses.init_pair(1, :black, :white)
    state
  end

  def setTitle(state) do
    new = Sys.get_directory_name(state)
    ExNcurses.attron(1)
    ExNcurses.mvprintw(0, 1, new.current_path)
    # ExNcurses.mvprintw(0, 1, Integer.to_string(ExNcurses.lines()))
    ExNcurses.attroff(1)
    ExNcurses.refresh()
    new
  end

  def loop(state) do
    receive do
      {:ex_ncurses, :key, key} ->
        state |> handle_key(key) |> loop

      :tick ->
        state |> schedule_next_tick |> loop
    end
  end

  defp handle_key(state, ?h), do: move_left(state)
  defp handle_key(state, ?k), do: move_up(state)
  defp handle_key(state, ?j), do: move_down(state)
  defp handle_key(state, ?l), do: move_right(state)
  defp handle_key(state, ?q), do: fin(state)
  defp handle_key(state, _), do: state

  defp move_left(state) do
    new = Sys.go_back(state)
    draw(new)
    new
  end

  defp move_right(state) do
    new = Sys.jump(state)
    draw(new)
    new
  end

  defp move_up(state) do
    if state.idx > 0 do
      new = %{state | idx: state.idx - 1}
      draw(new)
      new
    else
      state
    end
  end

  defp move_down(state) do
    if state.idx < length(state.dirs) - 1 do
      new = %{state | idx: state.idx + 1}
      draw(new)
      new
    else
      state
    end
  end

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

    lines = ExNcurses.lines()
    dirs_count = length(state.dirs)

    start_idx =
      if dirs_count > lines, do: max(0, state.idx - div(lines, 2)), else: 0

    end_idx =
      if dirs_count > lines, do: min(dirs_count - 1, start_idx + lines - 1), else: dirs_count - 1

    Enum.each(start_idx..end_idx, fn index ->
      filename = Enum.at(state.dirs, index)

      type_indicator =
        if File.dir?(Path.join([state.current_path, filename])) do
          "[folder]  "
        else
          "[file]    "
        end

      if index == state.idx do
        ExNcurses.attron(1)
        ExNcurses.mvprintw(index - start_idx + 1, 2, "#{type_indicator}#{filename}")
        ExNcurses.attroff(1)
      else
        ExNcurses.mvprintw(index - start_idx + 1, 2, "#{type_indicator}#{filename}")
      end
    end)

    state = setTitle(state)
    ExNcurses.refresh()
    state
  end

  defp flush_ticks() do
    receive do
      :tick -> flush_ticks()
    after
      100 ->
        :ok
    end
  end

  def fin(state) do
    System.cmd("cd", ["/"])
    flush_ticks()
    ExNcurses.stop_listening()
    :init.stop()
    ExNcurses.endwin()

    state
  end
end
