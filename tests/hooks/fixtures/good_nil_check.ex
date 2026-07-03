defmodule GoodNilCheck do
  def missing?(token), do: token == nil
  def unset?(secret), do: nil == secret
end
