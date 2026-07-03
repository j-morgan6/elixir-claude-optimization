defmodule GuardedC do
  def process_thing(item) when is_map(item) do
    validated = Map.put(item, :validated, true)
    normalized = Map.put(validated, :normalized_at, System.system_time(:second))
    Map.put(normalized, :status, :processed)
  end
end
