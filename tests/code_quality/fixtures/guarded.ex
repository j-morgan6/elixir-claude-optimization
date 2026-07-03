defmodule Guarded do
  def fetch(id) when is_integer(id), do: {:ok, id}
  def load(id) when is_integer(id), do: {:ok, id}
end
