defmodule BeeAdminWeb.ApiControllerTest do
  use BeeAdminWeb.ConnCase

  describe "health check API" do
    test "GET /api/health returns health status", %{conn: conn} do
      conn = get(conn, ~p"/api/health")
      assert json_response(conn, 200)["status"] == "healthy"
      assert json_response(conn, 200)["timestamp"]
    end
  end
end