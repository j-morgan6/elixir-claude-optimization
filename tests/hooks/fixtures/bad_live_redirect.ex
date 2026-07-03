defmodule BadNav do
  def link_home do
    live_redirect("Home", to: "/")
  end
end
