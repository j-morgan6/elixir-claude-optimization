defmodule BadLive do
  use Phoenix.LiveView

  @impl true
  def mount(_p, _s, socket), do: {:ok, socket}

  @impl true
  def handle_event(_event, _params, socket), do: {:noreply, socket}
end
