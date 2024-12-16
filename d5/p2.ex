defmodule P2 do
  def center(upd, hap_before) do
    acc_fn = fn p, acc ->
      a =
        if p in upd do
          1
        else
          0
        end

      acc + a
    end

    n_deps = fn page ->
      l =
        Map.get(hap_before, page)
        |> Enum.reduce(0, acc_fn)

      {page, l}
    end

    ord =
      Enum.map(upd, n_deps)
      |> Enum.sort_by(fn {_, a} -> a end, :desc)

    {x, _} = Enum.at(ord, Integer.floor_div(length(ord), 2))
    x
  end

  def printed?([], _) do
    true
  end

  def printed?([_ | []], _) do
    true
  end

  def printed?([pg1, pg2 | pgs], hap_before) do
    next =
      Map.get(hap_before, pg1)
      |> Enum.member?(pg2)

    if next do
      printed?([pg2 | pgs], hap_before)
    else
      false
    end
  end

  def find_printed([], _) do
    []
  end

  def find_printed([upd | upds], hap_before) do
    printed = printed?(upd, hap_before)

    if printed do
      [0 | find_printed(upds, hap_before)]
    else
      [center(upd, hap_before) | find_printed(upds, hap_before)]
    end
  end
end
