defmodule BeeAdminWeb.ApiController do
  use BeeAdminWeb, :controller

  def health_check(conn, _params) do
    conn
    |> put_status(:ok)
    |> json(%{status: "healthy", timestamp: DateTime.utc_now()})
  end
end