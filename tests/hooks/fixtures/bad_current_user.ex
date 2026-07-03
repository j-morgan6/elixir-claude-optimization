defmodule BadScopeUse do
  use Phoenix.Component

  def greeting(assigns) do
    ~H"""
    <p>Hello {@current_user.email}</p>
    """
  end
end
