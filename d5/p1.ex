defmodule P1 do
  def printed?([], _, _) do
    0
  end

  def printed?([_ | []], center, _) do
    center
  end

  def printed?([pg1, pg2 | pgs], center, hap_before) do
    next =
      Map.get(hap_before, pg1)
      |> Enum.member?(pg2)

    if next do
      printed?([pg2 | pgs], center, hap_before)
    else
      0
    end
  end

  def find_printed([], _) do
    []
  end

  def find_printed([upd | upds], hap_before) do
    center = Enum.at(upd, Integer.floor_div(length(upd), 2))
    [printed?(upd, center, hap_before) | find_printed(upds, hap_before)]
  end
end
