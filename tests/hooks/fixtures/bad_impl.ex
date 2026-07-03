defmodule BadLive do
  use Phoenix.LiveView
  def mount(_p, _s, socket), do: {:ok, socket}
end
