defmodule Main do
  def read_file() do
    bin = File.read!("./input.txt")
    [hap_before, updates] = String.split(bin, "\n\n")

    h =
      String.split(hap_before, "\n")
      |> Enum.map(fn x -> split_to_int(x, "|") end)

    u =
      String.split(updates, "\n")
      |> Enum.map(fn l -> split_to_int(l, ",") end)

    {h, u}
  end

  def split_to_int(s, pattern) do
    String.split(s, pattern, trim: true)
    |> Enum.map(fn x -> String.to_integer(x) end)
  end

  def reduce([], m) do
    m
  end

  def reduce([x | xs], m) do
    [h, t] = x

    m =
      if m[h] === nil do
        Map.put(m, h, [])
      else
        m
      end

    m = Map.put(m, h, Map.get(m, h) ++ [t])
    reduce(xs, m)
  end

  def main do
    {hap_before, updates} = read_file()

    m = %{}

    h = reduce(hap_before, m)

    printed =
      P1.find_printed(updates, h)
      |> Enum.reduce(0, fn x, acc -> acc + x end)

    p =
      P2.find_printed(updates, h)
      |> Enum.reduce(0, fn x, acc -> acc + x end)

    {printed, p}
  end
end
