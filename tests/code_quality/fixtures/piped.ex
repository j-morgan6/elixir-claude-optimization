defmodule Piped do
  def sum(list), do: list |> normalize |> Enum.sum()
  defp normalize(list), do: Enum.map(list, &abs/1)
end
