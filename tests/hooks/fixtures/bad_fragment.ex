defmodule Bad do
  import Ecto.Query
  def q(f), do: from(u in "users", where: fragment("lower(#{f})"))
end
