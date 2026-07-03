defmodule Bad do
  def role(params), do: String.to_atom(params["role"])
end
