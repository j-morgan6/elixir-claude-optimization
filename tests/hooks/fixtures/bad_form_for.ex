defmodule BadForm do
  def build(changeset) do
    form_for(changeset, "#", fn f -> f end)
  end
end
