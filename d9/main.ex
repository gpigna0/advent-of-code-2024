defmodule Main do
  def load() do
    bin = File.read!("./input.txt")
    String.split(bin, "", trim: true)
  end
end
