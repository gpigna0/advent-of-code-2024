defmodule LoadFile do
  def parse do
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

  def load do
    p = parse()
    h = length(p)
    w = p |> hd |> byte_size()
    {x, y} = find_start(p, 0)

    tup = fn s ->
      s
      |> String.split("", trim: true)
      |> List.to_tuple()
    end

    matrix = p |> Enum.map(tup) |> List.to_tuple()
    {matrix, w, h, x, y}
  end
end

defmodule Main do
  @area LoadFile.load()
  @mat elem(@area, 0)

  def obstacle(x, y, mat \\ @mat) do
    case mat |> elem(y) |> elem(x) do
      "#" ->
        true

      _ ->
        false
    end
  end

  def next({x, y, :up}, mat) do
    if obstacle(x, y - 1, mat), do: {x, y, :dx}, else: {x, y - 1, :up}
  end

  def next({x, y, :dx}, mat) do
    if obstacle(x + 1, y, mat), do: {x, y, :dn}, else: {x + 1, y, :dx}
  end

  def next({x, y, :dn}, mat) do
    if obstacle(x, y + 1, mat), do: {x, y, :sx}, else: {x, y + 1, :dn}
  end

  def next({x, y, :sx}, mat) do
    if obstacle(x - 1, y, mat), do: {x, y, :up}, else: {x - 1, y, :sx}
  end

  def oob({x, y, _}) do
    x <= 0 ||
      x >= elem(@area, 1) - 1 ||
      y <= 0 ||
      y >= elem(@area, 2) - 1
  end

  def loop(pos, iters, mat) do
    if iters <= 130 * 130 * 4 + 1 do
      n = next(pos, mat)
      if !oob(n), do: loop(n, iters + 1, mat), else: 0
    else
      1
    end
  end

  def rotate(:up), do: :dx
  def rotate(:dx), do: :dn
  def rotate(:dn), do: :sx
  def rotate(:sx), do: :up

  def can_loop({_, _, dir} = pos) do
    case next(pos, @mat) do
      {x, y, ^dir} ->
        if oob({x, y, dir}), do: false, else: can_loop({x, y, dir})

      # If dir changes it means that an obstacle is found
      _ ->
        true
    end
  end

  def trace({x, y, dir} = pos, visited, acc) do
    if !oob(pos) do
      np = next(pos, @mat)
      {nx, ny, _} = np

      a =
        if {nx, ny} not in visited do
          l_pos = {x, y, rotate(dir)}

          if can_loop(l_pos) do
            m = put_elem(@mat, ny, @mat |> elem(ny) |> put_elem(nx, "#"))
            acc + loop(l_pos, 0, m)
          else
            acc
          end
        else
          acc
        end

      v = visited ++ [{x, y}]
      trace(np, v, a)
    else
      acc
    end
  end

  def start do
    pos = {elem(@area, 3), elem(@area, 4), :up}
    trace(pos, [], 0)
  end
end

res = Main.start()
IO.puts(res)
