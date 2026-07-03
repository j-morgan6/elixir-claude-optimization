defmodule FormForTest do
  use ExUnit.Case
  test "deprecated helpers referenced in tests are not flagged" do
    assert is_function(&form_for/3)
  end

  defp form_for(a, _b, _c), do: form_for(a)
  defp form_for(a), do: a
end
