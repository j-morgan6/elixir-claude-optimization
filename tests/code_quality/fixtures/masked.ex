defmodule Masked do
  def run(x), do: renormalize(x)
  defp renormalize(x), do: x + 1
  defp normalize(x), do: x - 1
end
