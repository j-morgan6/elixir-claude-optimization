defmodule BadLogger do
  require Logger
  def log(user), do: Logger.info("login attempt with password #{user.password}")
end
