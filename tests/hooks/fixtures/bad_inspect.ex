defmodule BadInspect do
  def debug(user) do
    IO.inspect(user)
    user
  end
end
