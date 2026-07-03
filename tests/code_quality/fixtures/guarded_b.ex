defmodule GuardedB do
  def load_thing(id) when is_integer(id) do
    base = %{id: id, status: :active, retries: 0}
    stamped = Map.put(base, :fetched_at, System.system_time(:second))
    Map.put(stamped, :source, :primary_store)
  end
end
