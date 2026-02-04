defmodule LiveMonitorWeb.PageController do
  use LiveMonitorWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
