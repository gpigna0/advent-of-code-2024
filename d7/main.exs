defmodule Main do
  def load do
    {:ok, bin} = File.read("./input.txt")

    strings = String.split(bin, "\n", trim: true)

    Enum.map(strings, fn s ->
      [tgt, terms] = String.split(s, ": ")
      tgt = String.to_integer(tgt)
      terms = terms |> String.split(" ") |> Enum.map(fn x -> String.to_integer(x) end)
      {tgt, terms}
    end)
  end

  def calc1([], acc, target, caller), do: send(caller, acc === target)

  def calc1([n | ns], acc, target, caller) do
    spawn(fn -> calc1(ns, acc + n, target, caller) end)
    acc = if acc === 0, do: 1, else: acc
    spawn(fn -> calc1(ns, acc * n, target, caller) end)
  end

  def proc1([], acc) do
    IO.puts(acc)
  end

  def proc1([{tgt, list} | rest], acc) do
    pid = self()
    calc1(list, 0, tgt, pid)

    a =
      if Integer.pow(2, length(list)) |> rec(false) do
        acc + tgt
      else
        acc
      end

    proc1(rest, a)
  end

  ###############################################################################

  def calc2([], acc, target, caller), do: send(caller, acc === target)

  def calc2([n | ns], acc, target, caller) do
    spawn(fn -> calc2(ns, acc + n, target, caller) end)
    m = n |> Integer.digits() |> length()
    mul = Integer.pow(10, m)
    spawn(fn -> calc2(ns, acc * mul + n, target, caller) end)
    acc = if acc === 0, do: 1, else: acc
    spawn(fn -> calc2(ns, acc * n, target, caller) end)
  end

  def proc2([], acc) do
    IO.puts(acc)
  end

  def proc2([{tgt, list} | rest], acc) do
    pid = self()
    calc2(list, 0, tgt, pid)

    a =
      if Integer.pow(3, length(list)) |> rec(false) do
        acc + tgt
      else
        acc
      end

    proc2(rest, a)
  end

  #################################################################

  def rec(0, acc), do: acc

  def rec(qt, acc) do
    receive do
      v ->
        rec(qt - 1, v || acc)
    end
  end
end

a = Main.load()
Main.proc1(a, 0)
Main.proc2(a, 0)
