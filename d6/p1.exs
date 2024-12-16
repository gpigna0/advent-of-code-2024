defmodule Main do
  def load do
    {:ok, bin} = File.read("./input.txt")

    String.split(bin, "\n", trim: true)
  end

  def find_start([l | lns], y) do
    if String.contains?(l, "^") do
      [s | _] = String.split(l, "^", parts: 2)
      {byte_size(s), y}
    else
      find_start(lns, y + 1)
    end
  end

  def go(mat, x, y, acc, dir, next_dir) do
    next = mat |> elem(y) |> String.at(x)

    case next do
      "." ->
        bin = elem(mat, y)
        len = byte_size(bin)

        newline =
          Kernel.binary_part(bin, 0, x) <>
            "^" <>
            Kernel.binary_part(bin, len, x + 1 - len)

        m = put_elem(mat, y, newline)
        {m, acc + 1, dir}

      "^" ->
        {mat, acc, dir}

      "#" ->
        {mat, acc, next_dir}
    end
  end

  # start with acc = 1
  def next(mat, x, y, acc, :up) do
    h = tuple_size(mat)
    l = mat |> elem(0) |> byte_size()

    if x <= 0 || x >= l - 1 || y <= 0 || y >= h - 1 do
      acc
    else
      {m, a, dir} = go(mat, x, y - 1, acc, :up, :dx)

      if dir == :up, do: next(m, x, y - 1, a, dir), else: next(m, x, y, a, dir)
    end
  end

  def next(mat, x, y, acc, :dx) do
    h = tuple_size(mat)
    l = mat |> elem(0) |> byte_size()

    if x <= 0 || x >= l - 1 || y <= 0 || y >= h - 1 do
      acc
    else
      {m, a, dir} = go(mat, x + 1, y, acc, :dx, :dn)

      if dir == :dx, do: next(m, x + 1, y, a, dir), else: next(m, x, y, a, dir)
    end
  end

  def next(mat, x, y, acc, :dn) do
    h = tuple_size(mat)
    l = mat |> elem(0) |> byte_size()

    if x <= 0 || x >= l - 1 || y <= 0 || y >= h - 1 do
      acc
    else
      {m, a, dir} = go(mat, x, y + 1, acc, :dn, :sx)

      if dir == :dn, do: next(m, x, y + 1, a, dir), else: next(m, x, y, a, dir)
    end
  end

  def next(mat, x, y, acc, :sx) do
    h = tuple_size(mat)
    l = mat |> elem(0) |> byte_size()

    if x <= 0 || x >= l - 1 || y <= 0 || y >= h - 1 do
      acc
    else
      {m, a, dir} = go(mat, x - 1, y, acc, :sx, :up)

      if dir == :sx, do: next(m, x - 1, y, a, dir), else: next(m, x, y, a, dir)
    end
  end
end

matrix = Main.load()
{x, y} = Main.find_start(matrix, 0)
mat = List.to_tuple(matrix)
res = Main.next(mat, x, y, 1, :up)
IO.puts(:stdio, res)

# INFO: Part 2 abstract: check for obstacles in the next direction.
#       make split in two paths, one continuing, the other changing
#       direction. If the second path is a loop increment acc.
#       computation ends when the main path exits (order msgs with seq_num)
