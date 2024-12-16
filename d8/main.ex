defmodule Main do
  def load() do
    {:ok, bin} = File.read("./input.txt")

    lns = String.split(bin, "\n", trim: true)
    y_limit = length(lns)

    map = Enum.map(lns, fn l -> String.split(l, "", trim: true) end)
    x_limit = length(hd(map))

    antennas = y_collect(map, 0, %{})
    {antennas, x_limit, y_limit}
  end

  defp x_collect([], _, _, a), do: a

  defp x_collect([point | points], x, y, a) when point === "." or point === "#",
    do: x_collect(points, x + 1, y, a)

  defp x_collect([point | points], x, y, a) do
    pos = Map.get(a, point, [])
    a = Map.put(a, point, pos ++ [{x, y}])

    x_collect(points, x + 1, y, a)
  end

  defp y_collect([], _, a), do: a

  defp y_collect([line | lines], y, a) do
    a = x_collect(line, 0, y, a)
    y_collect(lines, y + 1, a)
  end

  def pairs([]), do: []

  def pairs([point | points]) do
    set =
      for pt <- points do
        {point, pt}
      end

    set ++ pairs(points)
  end

  def inside({x, y}, {x_limit, y_limit}) do
    0 <= x and x < x_limit and
      0 <= y and y < y_limit
  end

  def step(dist, {x, y} = pos, {xstp, ystp} = stp, limits) do
    p = {x + xstp * dist, y + ystp * dist}

    if inside(p, limits) do
      [p] ++ step(dist + 1, pos, stp, limits)
    else
      []
    end
  end

  def antinodes([], _, _), do: []

  def antinodes([{{x1, y1}, {x2, y2}} | pairs], limits, :p2) do
    step(0, {x1, y1}, {x1 - x2, y1 - y2}, limits) ++
      step(1, {x1, y1}, {x2 - x1, y2 - y1}, limits) ++
      antinodes(pairs, limits, :p2)
  end

  def antinodes([{{x1, y1}, {x2, y2}} | pairs], limits, :p1) do
    an = fn p1, p2 -> {2 * p1 - p2, 2 * p2 - p1} end
    {a1, a2} = an.(x1, x2)
    {b1, b2} = an.(y1, y2)
    n1 = {a1, b1}
    n2 = {a2, b2}

    if(inside(n1, limits), do: [n1], else: []) ++
      if(inside(n2, limits), do: [n2], else: []) ++
      antinodes(pairs, limits, :p1)
  end

  def search(antennas, limits, part) do
    anti = fn {t, l}, ant ->
      an = l |> pairs() |> antinodes(limits, part)
      Map.put(ant, t, an)
    end

    Enum.reduce(antennas, %{}, anti)
  end

  def qt(ant) do
    ant
    |> Enum.reduce([], fn {_, l}, acc -> acc ++ l end)
    |> Enum.uniq()
    |> length
  end

  def main() do
    {a, x, y} = load()

    res1 =
      a
      |> search({x, y}, :p1)
      |> qt

    res2 =
      a
      |> search({x, y}, :p2)
      |> qt

    {res1, res2}
  end
end
