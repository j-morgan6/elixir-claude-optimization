defmodule CleanTest do
  use ExUnit.Case
  test "atom ok in tests", do: assert String.to_atom("x") == :x
end
